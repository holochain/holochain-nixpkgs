use clap::{Parser, Subcommand};

/// Simple program to greet a person
#[derive(Parser, Debug)]
#[clap(author, version, about, long_about = None)]
struct CliArgs {
    /// Number of times to greet
    #[clap(short, long, default_value_t = 1)]
    verbose: u8,

    /// Name of the person to greet
    #[clap(subcommand)]
    cmd: Cmd,
}

#[derive(Debug, Subcommand)]
enum Cmd {
    UpdateHolochainTags(update_holochain_tags::CmdArgs),
}

#[tokio::main]
async fn main() {
    let cli_args = CliArgs::parse();

    match &cli_args.cmd {
        Cmd::UpdateHolochainTags(cmd_args) => update_holochain_tags::cmd(&cli_args, cmd_args).await,
    }
    .unwrap()
}

pub(crate) mod git_helper {
    use std::io::BufRead;

    use anyhow::bail;

    pub(crate) async fn ls_remote_tags(
        url: &str,
        glob_filter: &str,
    ) -> anyhow::Result<Vec<String>> {
        let mut cmd = std::process::Command::new("git");
        cmd.args(&["ls-remote", "--tags", "--refs", url, glob_filter]);

        let output = cmd.output()?;

        if !output.status.success() {
            bail!("running {:#?} failed:\n{:#?}", cmd, output);
        }

        // looks something like this
        // 6535292238dc1fbd2b60433a2054f7787e4f060e	refs/tags/holochain-0.0.102
        // (...)
        // c77901e614e653adaa17e80b41db67f8a4fa5b88	refs/tags/holochain-0.0.127
        let lines = output
            .stdout
            .lines()
            .filter_map(|l| l.ok())
            .filter_map(|l| -> Option<String> {
                l.split("\t")
                    .last()
                    .map(|s| s.replace("refs/tags/", "").to_string())
            })
            .collect();

        Ok(lines)
    }
}

mod update_holochain_tags {

    use std::{
        collections::HashSet,
        fs::OpenOptions,
        io::{Read, Seek, SeekFrom, Write},
        os::unix::prelude::FileExt,
        path::PathBuf,
    };

    use anyhow::bail;
    use linked_hash_set::LinkedHashSet;

    #[derive(clap::Args, Debug)]
    pub(crate) struct CmdArgs {
        #[clap(long)]
        dry_run: bool,

        #[clap(long, default_value_t = 10)]
        keep_tags: u8,

        #[clap(long, default_value = ".github/workflows/build.yml")]
        build_yaml_path: PathBuf,

        #[clap(long, default_value = "packages/holochain/versions/update_config.toml")]
        update_config_toml_path: PathBuf,

        #[clap(long, default_value = "https://github.com/holochain/holochain.git")]
        holochain_git_url: String,

        #[clap(long, default_value = "~0.0")]
        default_lair_version_req: String,
    }

    pub(crate) async fn cmd(_cli_args: &super::CliArgs, cmd_args: &CmdArgs) -> anyhow::Result<()> {
        const TAG_GLOB_PREFIX: &str = "holochain-";

        // get the holochain tags from the holochain repo
        let tags = crate::git_helper::ls_remote_tags(
            &cmd_args.holochain_git_url,
            &format!("{}*", TAG_GLOB_PREFIX),
        )
        .await?
        .into_iter()
        .map(|tag| {
            let compat = tag.replace(TAG_GLOB_PREFIX, "");
            let compat = compat.replacen(".", "_", 2);

            (tag, format!("v{}", compat))
        })
        .collect::<Vec<(_, _)>>();
        println!("latest tags: {:#?}", tags);

        // make sure the latest tags exist in the build.yml
        let (removed_entries, added_entries_build_yml) = {
            let mut build_yaml: serde_yaml::Value =
                serde_yaml::from_reader(&std::fs::File::open(&cmd_args.build_yaml_path)?)?;

            let mut nix_attributes = &mut build_yaml;
            for attr in [
                "jobs",
                "holochain-binaries",
                "strategy",
                "matrix",
                "nixAttribute",
            ] {
                nix_attributes = nix_attributes
                    .get_mut(&attr)
                    .ok_or_else(|| anyhow::anyhow!("can't access {}", attr))?;
            }
            let nix_attributes = nix_attributes
                .as_sequence_mut()
                .ok_or_else(|| anyhow::anyhow!("nix_attributes is not a sequence"))?;

            let entries_orig =
                HashSet::<serde_yaml::Value>::from_iter(nix_attributes.iter().cloned());

            println!("nix_attributes: {:?}", nix_attributes);

            // keep only a limited number of entries. treat the ones tarting with `v[0-9]` as replacable
            let prefix_re = regex::Regex::new("^v[0-9]+")?;
            nix_attributes.retain(|value| match value {
                serde_yaml::Value::String(s) => !prefix_re.is_match(s),
                other => panic!("unexpected entry in nix_attributes: {:?}", other),
            });
            let space_left = cmd_args.keep_tags as usize - nix_attributes.len();
            for (_, compat_tag) in tags.iter().skip(tags.len() - space_left) {
                nix_attributes.push(serde_yaml::Value::String(compat_tag.clone()));
            }

            let entries_new =
                HashSet::<serde_yaml::Value>::from_iter(nix_attributes.iter().cloned());

            anyhow::ensure!(cmd_args.keep_tags as usize == nix_attributes.len(),);

            println!("new nix_attributes:\n{:?}", nix_attributes);

            let build_yaml_content = {
                let mut output = vec![];
                serde_yaml::to_writer(&mut output, &build_yaml)?;
                String::from_utf8(output)?
            };

            println!("new file content:\n{}", &build_yaml_content);

            if !cmd_args.dry_run {
                std::fs::File::create(&cmd_args.build_yaml_path)?
                    .write_all_at(build_yaml_content.as_bytes(), 0)?;
            }

            (
                entries_orig
                    .difference(&entries_new)
                    .map(|v| v.as_str().unwrap().to_string())
                    .collect::<LinkedHashSet<_>>(),
                entries_new
                    .difference(&entries_orig)
                    .map(|v| v.as_str().unwrap().to_string())
                    .collect::<LinkedHashSet<_>>(),
            )
        };

        // add the missing tags to the update_config.toml
        let added_entries_update_config = {
            let mut update_config_toml = OpenOptions::new()
                .create(true)
                .write(true)
                .read(true)
                .open(&cmd_args.update_config_toml_path)?;

            let mut update_config_toml_editable = {
                let mut buf = String::new();
                update_config_toml.read_to_string(&mut buf)?;
                buf.parse::<toml_edit::Document>()?
            };

            let mut added_entries = LinkedHashSet::new();

            for (tag, compat) in tags {
                // ensure nixpkgs is set
                if update_config_toml_editable[&compat].is_none() {
                    update_config_toml_editable[&compat] = toml_edit::table();
                    update_config_toml_editable[&compat]["git-src"] =
                        toml_edit::value(format!("revision:{}", tag));
                    update_config_toml_editable[&compat]["lair-version-req"] =
                        toml_edit::value(&cmd_args.default_lair_version_req);

                    added_entries.insert(compat);
                }
            }

            // write back to file
            if !cmd_args.dry_run {
                update_config_toml.seek(SeekFrom::Start(0))?;
                update_config_toml.write_all(update_config_toml_editable.to_string().as_bytes())?;
                update_config_toml
                    .set_len(update_config_toml_editable.to_string().as_bytes().len() as u64)?;
            }

            added_entries
        };

        if added_entries_build_yml != added_entries_update_config {
            println!(
                "warning: symmetric difference between build.yml and update_config.toml: {:#?}",
                added_entries_build_yml.symmetric_difference(&added_entries_update_config)
            );
        }

        let msg = indoc::formatdoc!(
            r#"udpated config files with new holochain tags

            removed {:#?}

            added {:#?}
            "#,
            &removed_entries,
            &added_entries_build_yml
        );

        println!("{}", msg);

        if removed_entries.is_empty()
            && added_entries_build_yml.is_empty()
            && added_entries_update_config.is_empty()
        {
            return Ok(());
        }

        // commit the config files
        {
            let mut cmd = std::process::Command::new("git");
            cmd.args(&[
                "commit",
                "-F",
                "-",
                &cmd_args
                    .build_yaml_path
                    .as_os_str()
                    .to_string_lossy()
                    .to_string(),
                &cmd_args
                    .update_config_toml_path
                    .as_os_str()
                    .to_string_lossy()
                    .to_string(),
            ])
            .stdin(std::process::Stdio::piped());

            println!(
                "{}running command: {:?}",
                if cmd_args.dry_run { "[DRY_RUN] " } else { "" },
                cmd
            );

            if !cmd_args.dry_run {
                let mut child = cmd.spawn()?;
                let mut stdin = child.stdin.take().expect("could not open child's stdin");
                std::thread::spawn(move || {
                    stdin
                        .write_all(msg.as_bytes())
                        .expect("Failed to write commit msg to stdin");
                });
                let output = child.wait_with_output()?;
                if !output.status.success() {
                    bail!("running {:#?} failed:\n{:#?}", cmd, output);
                }
            }
        }

        // generate the version files for the newly added tags
        for compat_tag in added_entries_update_config {
            let mut cmd = std::process::Command::new("hnixpkgs-update-single");
            cmd.arg(&compat_tag);

            println!(
                "{}running command: {:?}",
                if cmd_args.dry_run { "[DRY_RUN] " } else { "" },
                cmd
            );

            if !cmd_args.dry_run {
                let output = cmd.output()?;
                if !output.status.success() {
                    println!("running command {:#?} failed:\n{:#?}", cmd, output);
                }
            }
        }

        Ok(())
    }
}

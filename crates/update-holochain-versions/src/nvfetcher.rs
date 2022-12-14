use anyhow::Context;
use std::{
    collections::HashMap,
    fs::OpenOptions,
    io::{Read, Seek, SeekFrom, Write},
    path::PathBuf,
    process::Command,
};
use tempfile::tempdir;
use toml_edit::Document;

use crate::update_config::GitSrc;

type Fallible<T> = anyhow::Result<T>;

#[derive(serde::Serialize, serde::Deserialize)]
pub struct BinCrateSource<'a> {
    pub name: &'a str,
    pub git_repo: &'a str,
    pub git_src: GitSrc,
    pub bins_filter: Vec<String>,
}

impl<'a> BinCrateSource<'a> {
    pub fn crate_toml_key(&self) -> String {
        format!(
            "{}_{}",
            self.name,
            (&self.git_src)
                .to_string()
                .replace(":", "_")
                .replace(".", "_")
        )
    }
}
pub struct NvfetcherWrapper<'a> {
    pub src: BinCrateSource<'a>,
    pub nvfetcher_dir: PathBuf,
    pub crate_toml_key: String,
}

#[derive(Debug, serde::Deserialize, PartialEq)]
#[serde(rename_all = "camelCase")]
pub struct NvfetcherCrateSrcEntry {
    pub name: String,
    pub version: String,
    pub src: FetchgitSrcPartial,
    pub cargo_lock: String,
    pub rust_git_deps: HashMap<String, String>,
}

impl NvfetcherCrateSrcEntry {
    pub fn semver(&self) -> Fallible<semver::Version> {
        let split = self
            .version
            .split_once("-")
            .map(|split| split.1)
            .ok_or_else(|| anyhow::anyhow!("could not parse {}", self.version))?;
        Ok(semver::Version::parse(&split).context(format!("parsing {} to a SemVer", split))?)
    }
}

#[derive(Debug, serde::Deserialize, PartialEq)]
pub struct FetchgitSrcPartial {
    pub url: String,
    pub rev: String,
    pub sha256: String,
}

macro_rules! ctx {
    ($all:expr) => {
        $all.context(format!("{}:{}: {}", file!(), line!(), stringify!($all)))
    };
}

impl<'a> NvfetcherWrapper<'a> {
    pub fn new(
        src: BinCrateSource<'a>,
        nvfetcher_dir: Option<PathBuf>,
        override_crate_toml_key: Option<String>,
    ) -> Fallible<Self> {
        let (mut nvfetcher_dir, _tmpdir) = if let Some(path) = nvfetcher_dir {
            std::fs::create_dir_all(&path)?;
            (path, None)
        } else {
            let tmpdir = tempdir()?;
            let tmppath = tmpdir.path().to_path_buf();
            (tmppath, Some(tmpdir))
        };

        if !nvfetcher_dir.is_absolute() {
            nvfetcher_dir = std::env::current_dir()?.join(nvfetcher_dir)
        };

        let crate_toml_key = if let Some(key) = override_crate_toml_key {
            key
        } else {
            src.crate_toml_key()
        };

        Ok(Self {
            src,
            nvfetcher_dir,
            crate_toml_key,
        })
    }

    /// This will fetch all the sources that are specified via the _nvfetcher.toml_ file and update the generated nix file.
    pub fn fetch_and_regen_srcinfo(&self) -> Fallible<()> {
        ctx!(std::fs::create_dir_all(&self.nvfetcher_dir))?;

        let mut nvfetcher_build_filters = vec![self.crate_toml_key.as_str()];

        {
            let nvfetcher_toml_path = self.nvfetcher_dir.join("nvfetcher.toml");

            let mut nvfetcher_toml_file = ctx!(OpenOptions::new()
                .create(true)
                .write(true)
                .read(true)
                .open(&nvfetcher_toml_path))?;
            let mut nvfetcher_toml_editable = {
                let mut buf = String::new();
                ctx!(nvfetcher_toml_file.read_to_string(&mut buf))?;
                ctx!(buf.parse::<toml_edit::Document>())?
            };

            use toml_edit::{table, value};

            let init_table = |doc: &mut Document, lvl1path, lvl2paths: &[&str]| {
                doc[lvl1path] = table();
                for lvl2path in lvl2paths {
                    doc[lvl1path][lvl2path] = table();
                    doc[lvl1path][lvl2path]
                        .as_table_mut()
                        .expect("newly created table is not present")
                        .set_dotted(true);
                }
            };

            // ensure nixpkgs is set
            if nvfetcher_toml_editable["nixpkgs"].is_none() {
                nvfetcher_build_filters.push("nixpkgs");
                init_table(
                    &mut nvfetcher_toml_editable,
                    "nixpkgs",
                    &["src", "fetch", "git"],
                );

                nvfetcher_toml_editable["nixpkgs"]["src"]["git"] =
                    value("https://github.com/nixos/nixpkgs");
                nvfetcher_toml_editable["nixpkgs"]["fetch"]["tarball"] =
                    value("https://github.com/nixos/nixpkgs/archive/$ver.tar.gz");
                nvfetcher_toml_editable["nixpkgs"]["src"]["branch"] = value("release-22.11");
            }

            // ensure the crate source is set
            let (git_src_keys, git_src_value) = self.src.git_src.toml_src_value();

            init_table(
                &mut nvfetcher_toml_editable,
                &self.crate_toml_key,
                &["src", "fetch", git_src_keys[0]],
            );

            nvfetcher_toml_editable[&self.crate_toml_key]["cargo_lock"] = value("Cargo.lock");

            {
                let mut tmp = nvfetcher_toml_editable[&self.crate_toml_key]
                    .as_table_mut()
                    .unwrap();

                for key in git_src_keys.iter().take(git_src_keys.len() - 1) {
                    tmp[key] = table();
                    tmp = tmp[key].as_table_mut().unwrap();
                    tmp.set_dotted(true);
                }

                tmp[git_src_keys.last().unwrap()] = value(git_src_value);
            }

            if !self.src.git_src.is_rev() {
                nvfetcher_toml_editable[&self.crate_toml_key]["src"]["git"] =
                    value(self.src.git_repo);
            }
            nvfetcher_toml_editable[&self.crate_toml_key]["fetch"]["git"] =
                value(self.src.git_repo);

            // write back to file
            nvfetcher_toml_file.seek(SeekFrom::Start(0))?;
            nvfetcher_toml_file.write_all(nvfetcher_toml_editable.to_string().as_bytes())?;
            nvfetcher_toml_file
                .set_len(nvfetcher_toml_editable.to_string().as_bytes().len() as u64)?;

            eprintln!(
                "wrote nvfetcher config at {}:\n{}",
                nvfetcher_toml_path.display(),
                ctx!(std::fs::read_to_string(&nvfetcher_toml_path))?
            );
        }

        {
            let mut cmd = Command::new("nvfetcher");
            cmd.current_dir(&self.nvfetcher_dir)
                .args(&[
                    "build", // TODO: insert a --filter
                    &format!("--filter=({})", nvfetcher_build_filters.join("|")),
                ])
                .stdout(std::process::Stdio::inherit())
                .stderr(std::process::Stdio::inherit());
            eprintln!(
                "running the following cmd: {:#?} in {}",
                cmd,
                &self.nvfetcher_dir.display()
            );

            ctx!(match cmd.output() {
                Ok(output) if output.status.success() => Ok(()),
                Ok(details) => Err(anyhow::anyhow!("{:#?}", details)),
                Err(err) => Err(anyhow::Error::from(err)),
            }
            .context(format!("{:#?} failed", cmd)))?;
        }

        Ok(())
    }

    pub fn get_crate_srcinfo(&'a self, update: bool) -> Fallible<NvfetcherCrateSrcEntry> {
        if update {
            self.fetch_and_regen_srcinfo()?;
        }

        let generated_path = self.nvfetcher_dir.join("_sources/generated.json");

        let json: serde_json::Value =
            serde_json::from_reader(&std::fs::File::open(&generated_path)?)?;

        let json_crate_only = json.get(&self.crate_toml_key).ok_or_else(|| {
            anyhow::anyhow!(
                "could not find entry for {} in data:\n{}",
                &self.crate_toml_key,
                serde_json::to_string_pretty(&json).unwrap_or_default()
            )
        })?;

        serde_json::from_value(json_crate_only.clone()).context(format!(
            "error parsing\n{}",
            serde_json::to_string_pretty(json_crate_only).unwrap_or_default()
        ))
    }
}

#[cfg(test)]
mod tests {

    use super::*;

    const NVFETCHER_EXAMPLE_GENERATED: &str = r#"
{
    "holochain": {
        "pinned": true,
        "cargoLock": "./holochain_revision_holochain-0_0_122-holochain-0.0.122/Cargo.lock",
        "name": "holochain_revision_holochain-0_0_122",
        "version": "holochain-0.0.122",
        "passthru": null,
        "src": {
            "deepClone": false,
            "url": "https://github.com/holochain/holochain",
            "leaveDotGit": false,
            "fetchSubmodules": false,
            "name": null,
            "type": "git",
            "sha256": "sha256-ptTOz1CVWBPMawoYdJJKlOQqweuSrCmjcgCw7sA9VyA=",
            "rev": "holochain-0.0.122"
        },
        "extract": null,
        "rustGitDeps": {
            "cargo-test-macro-0.1.0": "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs="
        }
    }
}"#;

    #[test]
    fn nvfetcher_struct_from_json() {
        let json: serde_json::Value =
            serde_json::from_reader::<_, serde_json::Value>(NVFETCHER_EXAMPLE_GENERATED.as_bytes())
                .unwrap()
                .as_object()
                .unwrap()
                .get("holochain")
                .unwrap()
                .to_owned();

        let result: NvfetcherCrateSrcEntry = serde_json::from_value(json).unwrap();

        let expected = NvfetcherCrateSrcEntry {
            name: "holochain_revision_holochain-0_0_122".to_string(),
            version: "holochain-0.0.122".to_string(),
            src: FetchgitSrcPartial {
                url: "https://github.com/holochain/holochain".to_string(),
                rev: "holochain-0.0.122".to_string(),
                sha256: "sha256-ptTOz1CVWBPMawoYdJJKlOQqweuSrCmjcgCw7sA9VyA=".to_string(),
            },
            cargo_lock: "./holochain_revision_holochain-0_0_122-holochain-0.0.122/Cargo.lock"
                .to_string(),
            rust_git_deps: maplit::hashmap! {
                "cargo-test-macro-0.1.0" => "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs="
            }
            .iter()
            .map(|(k, v)| (k.to_string(), v.to_string()))
            .collect::<HashMap<String, String>>(),
        };

        assert_eq!(expected, result);
    }
}

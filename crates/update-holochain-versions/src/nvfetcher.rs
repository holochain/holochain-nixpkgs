type Fallible<T> = anyhow::Result<T>;
use std::{
    collections::HashMap,
    fs::OpenOptions,
    io::{Read, Seek, SeekFrom, Write},
    path::PathBuf,
    process::Command,
};

use anyhow::Context;
use once_cell::sync::OnceCell;
use tempfile::tempdir;
use toml_edit::Document;

use crate::BinCrateSource;

pub(crate) struct NvfetcherWrapper<'a> {
    pub(crate) src: BinCrateSource<'a>,
    pub(crate) nvfetcher_dir: PathBuf,
    // pub(crate) tmpdir: Option<TempDir>,
    pub(crate) crate_srcinfo: OnceCell<NvfetcherCrateSrcEntry>,
    pub(crate) crate_toml_key: String,
}

#[derive(Debug, serde::Deserialize, PartialEq)]
#[serde(rename_all = "camelCase")]
pub(crate) struct NvfetcherCrateSrcEntry {
    pub(crate) pname: String,
    pub(crate) version: String,
    pub(crate) src: FetchgitSrcPartial,
    pub(crate) cargo_lock: CargoLockPartial,
}

#[derive(Debug, serde::Deserialize, PartialEq)]
pub(crate) struct FetchgitSrcPartial {
    pub(crate) url: String,
    pub(crate) rev: String,
    pub(crate) sha256: String,
}

#[derive(Debug, serde::Deserialize, PartialEq)]
#[serde(rename_all = "camelCase")]
pub(crate) struct CargoLockPartial {
    pub(crate) output_hashes: HashMap<String, String>,
}

fn nix_to_json_partial<R: std::io::Read>(mut input: R) -> Fallible<serde_json::Value> {
    let mut buf = String::new();
    input.read_to_string(&mut buf)?;
    let output = buf;

    let output = regex::Regex::new(r"\{ (fetch.+,?)+ }:")
        .unwrap()
        .replace_all(&output, r#""#);

    let output = regex::Regex::new(r"#.*")
        .unwrap()
        .replace_all(&output, r#""#);

    let output = regex::Regex::new(r"(?P<key>(_|-|\w)+) = ")
        .unwrap()
        .replace_all(&output, r#""${key}" = "#);

    let output = regex::Regex::new(r#"" = "#)
        .unwrap()
        .replace_all(&output, r#"": "#);

    let output = regex::Regex::new(r"fetch(url|FromGitHub|git) \(?\{")
        .unwrap()
        .replace_all(&output, r#"{"#);

    let output = regex::Regex::new(r"\}\)")
        .unwrap()
        .replace_all(&output, r#"}"#);

    let output = regex::Regex::new(r";")
        .unwrap()
        .replace_all(&output, r#","#);

    let output = regex::Regex::new(r#": (?P<val>\.[^",]+),"#)
        .unwrap()
        .replace_all(&output, r#": "${val}","#);

    let json: serde_json::Value =
        json5::from_str(&output).context(format!("parsing json5 from:\n{}", &output))?;

    Ok(json)
}

impl<'a> NvfetcherWrapper<'a> {
    pub(crate) fn new(
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
            // tmpdir,
            crate_srcinfo: Default::default(),
            crate_toml_key,
        })
    }

    pub(crate) fn get_crate_srcinfo(&self) -> Fallible<&NvfetcherCrateSrcEntry> {
        self.crate_srcinfo.get_or_try_init(|| {
            macro_rules! ctx {
                ($all:expr) => {
                    $all.context(format!("{}:{}: {}", file!(), line!(), stringify!($all)))
                };
            }

            let nvfetcher_dir = self.nvfetcher_dir.clone();
            let crate_toml_key = &self.crate_toml_key;

            ctx!(std::fs::create_dir_all(&nvfetcher_dir))?;

            {
                let nvfetcher_toml_path = nvfetcher_dir.join("nvfetcher.toml");

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
                // if nvfetcher_toml_editable["nixpkgs"].is_none() {
                init_table(
                    &mut nvfetcher_toml_editable,
                    "nixpkgs",
                    &["src", "fetch", "git"],
                );

                nvfetcher_toml_editable["nixpkgs"]["src"]["git"] =
                    value("https://github.com/nixos/nixpkgs");
                nvfetcher_toml_editable["nixpkgs"]["fetch"]["github"] = value("nixos/nixpkgs");
                nvfetcher_toml_editable["nixpkgs"]["src"]["branch"] = value("release-21.05");
                // }

                // ensure the crate source is set
                let (git_src_keys, git_src_value) = self.src.git_rev.toml_src_value();

                init_table(
                    &mut nvfetcher_toml_editable,
                    crate_toml_key,
                    &["src", "fetch", git_src_keys[0]],
                );

                nvfetcher_toml_editable[crate_toml_key]["cargo_lock"] = value("Cargo.lock");

                {
                    let mut tmp = nvfetcher_toml_editable[crate_toml_key]
                        .as_table_mut()
                        .unwrap();

                    for key in git_src_keys.iter().take(git_src_keys.len() - 1) {
                        tmp[key] = table();
                        tmp = tmp[key].as_table_mut().unwrap();
                        tmp.set_dotted(true);
                    }

                    tmp[git_src_keys.last().unwrap()] = value(git_src_value);
                }

                if !self.src.git_rev.is_manual() {
                    nvfetcher_toml_editable[crate_toml_key]["src"]["git"] =
                        value(self.src.git_repo);
                }
                nvfetcher_toml_editable[crate_toml_key]["fetch"]["git"] = value(self.src.git_repo);

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
                cmd.current_dir(&nvfetcher_dir)
                    .args(&["build"])
                    .stdout(std::process::Stdio::inherit())
                    .stderr(std::process::Stdio::inherit());
                eprintln!(
                    "running the following cmd: {:#?} in {}",
                    cmd,
                    nvfetcher_dir.display()
                );

                ctx!(match cmd.output() {
                    Ok(output) if output.status.success() => Ok(()),
                    Ok(details) => Err(anyhow::anyhow!("{:#?}", details)),
                    Err(err) => Err(anyhow::Error::from(err)),
                }
                .context(format!("{:#?} failed", cmd)))?;
            }

            {
                let generated_path = nvfetcher_dir.join("_sources/generated.nix");

                let nix = ctx!(std::fs::File::open(&generated_path))?;
                let json = nix_to_json_partial(nix)?;

                let json_crate_only = json.get(crate_toml_key).ok_or_else(|| {
                    anyhow::anyhow!(
                        "could not find entry for {} in data:\n{}",
                        crate_toml_key,
                        serde_json::to_string_pretty(&json).unwrap_or_default()
                    )
                })?;

                serde_json::from_value(json_crate_only.clone()).context(format!(
                    "error parsing\n{}",
                    serde_json::to_string_pretty(json_crate_only).unwrap_or_default()
                ))
            }
        })
    }
}

#[cfg(test)]
mod tests {

    use super::*;

    const _FIXTURE1: &str = r#"
        # TODO: automate updating these
        # 0. bump ${attrName}.holochain.rev
        # 1. set all sha256 and cargoSha256 to "0000000000000000000000000000000000000000000000000000"
        # 2. build holochain: nix build -f default.nix packages.holochainAllBinariesWithDeps.${attrName}.holochain
        # 3. replace ${attrName}.holochain.sha256 with output
        # 4. build holochain: nix build -f default.nix packages.holochainAllBinariesWithDeps.${attrName}.holochain
        # 5. replace ${attrName}.holochain.cargoSha256 with output
        # 6. build lair-keystore: nix build -f default.nix packages.holochainAllBinariesWithDeps.${attrName}.lair-keystore
        # 7. replace ${attrName}.lair-keystore.sha256 with output
        # 8. build lair-keystore: nix build -f default.nix packages.holochainAllBinariesWithDeps.${attrName}.lair-keystore
        # 10. replace ${attrName}.lair-keystore.cargoSha256 with output

        {
            develop = {
                rev = "cacb6af9d733bcd782a04a9f4b0a72e520433a6e";
                sha256 = "18lc87z6pmbyzffgpi6b6jcikb44a0c4bmjzvvf7l4dgqmm2xbm6";
                cargoSha256 = "19z2qakhhvwrva16ycq4zpnhl0xhksli8jknfpr1l2sxfbm2zjiw";
                bins = {
                    holochain = "holochain";
                    hc = "hc";
                    kitsune-p2p-proxy = "kitsune_p2p/proxy";
                };

                lairKeystoreHashes = {
                    sha256 = "0khg5w5fgdp1sg22vqyzsb2ri7znbxiwl7vr2zx6bwn744wy2cyv";
                    cargoSha256 = "1lm8vrxh7fw7gcir9lq85frfd0rdcca9p7883nikjfbn21ac4sn4";
                };
            };

            main = {
                rev = "holochain-0.0.103";
                sha256 = "1z0y1bl1j2cfv4cgr4k7y0pxnkbiv5c0xv89y8dqnr32vli3bld7";
                cargoSha256 = "1rf8vg832qyymw0a4x247g0iikk6kswkllfrd5fqdr0qgf9prc31";
                bins = {
                    holochain = "holochain";
                    hc = "hc";
                    kitsune-p2p-proxy = "kitsune_p2p/proxy";
                };

                lairKeystoreHashes = {
                    sha256 = "1jiz9y1d4ybh33h1ly24s7knsqyqjagsn1gzqbj1ngl22y5v3aqh";
                    cargoSha256 = "0agykcl7ysikssfwkjgb3hfw6xl0slzy38prc4rnzvagm5wd1jjv";
                };
            };
        }
    "#;

    const NVFETCHER_EXAMPLE_GENERATED: &str = r#"
# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl }:
{
  holochain = {
    pname = "holochain";
    version = "3c1d86a9aa921e96f68d762557a016bd6bbe431b";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "3c1d86a9aa921e96f68d762557a016bd6bbe431b";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "1xjhjggzvw0vysv83fl5pla16ami5yp1ac4y15233g7w1s2g4l3k";
    };
    cargoLock = {
      lockFile = ./holochain-3c1d86a9aa921e96f68d762557a016bd6bbe431b/Cargo.lock;
      outputHashes = {
        "cargo-test-macro-0.1.0" = "1yy1y1d523xdzwg1gc77pigbcwsbawmy4b7vw8v21m7q957sk0c4";
        "another-crate-macro-0.1.0" = "0yy1y1d523xdzwg1gc77pigbcwsbawmy4b7vw8v21m7q957sk0c4";
      };
    };
  };
}"#;

    #[test]
    fn nvfetcher_struct_from_json() {
        let json: serde_json::Value = nix_to_json_partial(NVFETCHER_EXAMPLE_GENERATED.as_bytes())
            .unwrap()
            .as_object()
            .unwrap()
            .get("holochain")
            .unwrap()
            .to_owned();

        let result: super::NvfetcherCrateSrcEntry = serde_json::from_value(json).unwrap();

        let expected = NvfetcherCrateSrcEntry {
            pname: "holochain".to_string(),
            version : "3c1d86a9aa921e96f68d762557a016bd6bbe431b".to_string(),
            src : FetchgitSrcPartial{
                url : "https://github.com/holochain/holochain".to_string(),
                rev : "3c1d86a9aa921e96f68d762557a016bd6bbe431b".to_string(),
                sha256 : "1xjhjggzvw0vysv83fl5pla16ami5yp1ac4y15233g7w1s2g4l3k".to_string(),
            },
            cargo_lock: CargoLockPartial {
                output_hashes: maplit::hashmap! {
                    "another-crate-macro-0.1.0" => "0yy1y1d523xdzwg1gc77pigbcwsbawmy4b7vw8v21m7q957sk0c4",
                    "cargo-test-macro-0.1.0" => "1yy1y1d523xdzwg1gc77pigbcwsbawmy4b7vw8v21m7q957sk0c4"
                }
                .iter().map(|(k,v)| (k.to_string(), v.to_string())).collect::<HashMap<String, String>>(),
            },
        };

        assert_eq!(expected, result);
    }
}

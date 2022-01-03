use anyhow::{bail, Context};
use once_cell::sync::Lazy;
use std::{
    collections::HashMap,
    path::PathBuf,
    process::{Command, ExitStatus},
    str::FromStr,
};
use structopt::StructOpt;
use tempfile::tempdir;
use url::Url;

use crate::nvfetcher::NvfetcherWrapper;

mod nvfetcher;

type Fallible<T> = anyhow::Result<T>;

/// This utility will write Nix code to `output_file`, that is tailored to be used as a specifier for which holochain repository to use, and which binaries to install from it.
#[derive(Debug, StructOpt)]
struct Opt {
    #[structopt(long)]
    nvfetcher_dir: Option<PathBuf>,

    #[structopt(long, default_value = "holochain_version.nix")]
    output_file: PathBuf,

    /// Specifier for the holochain git repository
    #[structopt(long, default_value = "https://github.com/holochain/holochain")]
    git_repo: String,

    /// Git source specifier for fetching the holochain sources.
    /// Either: branch:<branch_name> or revision:<rev>
    #[structopt(long)]
    git_src: GitSrc,

    /// Specifier for the lair git repository
    #[structopt(long, default_value = "https://github.com/holochain/lair")]
    lair_git_repo: String,

    /// Specifier for the lair version requirement
    #[structopt(long, default_value = "*")]
    lair_version_req: semver::VersionReq,

    #[structopt(
        long,
        default_value = "holochain,hc,kitsune-p2p-proxy",
        use_delimiter = true
    )]
    bins_filter: Vec<String>,
}

/// Parse a comma separated list of key:value pairs into a map
pub fn parse_hashmap(src: &str) -> HashMap<String, String> {
    src.replace('"', "")
        .split(',')
        .filter_map(|s| {
            s.trim()
                .to_lowercase()
                .split_once(':')
                .map(|(k, v)| (k.to_string(), v.to_string()))
        })
        .collect()
}

#[derive(serde::Serialize, serde::Deserialize)]
struct BinCrateSource<'a> {
    name: &'a str,
    git_repo: &'a str,
    git_src: GitSrc,
    bins_filter: Vec<String>,
}

impl<'a> BinCrateSource<'a> {
    fn crate_toml_key(&self) -> String {
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

#[derive(Clone, Debug, serde::Serialize, serde::Deserialize)]
enum GitSrc {
    Branch(String),
    Revision(String),
}

impl std::fmt::Display for &GitSrc {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str(&match self {
            GitSrc::Branch(branch) => format!("branch:{}", branch),
            GitSrc::Revision(rev) => format!("revision:{}", rev),
        })
    }
}

impl FromStr for GitSrc {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let s = s.to_string();
        let split = s
            .splitn::<_>(2, ':')
            .map(|s| s.to_lowercase())
            .map(|s| s.trim().to_owned())
            .map(|s| s.replace('"', ""))
            .collect::<Vec<_>>();
        match (split.get(0), split.get(1)) {
            (Some(key), Some(branch)) if key == "branch" => Ok(GitSrc::Branch(branch.clone())),
            (Some(key), Some(rev)) if key == "revision" => Ok(GitSrc::Revision(rev.clone())),
            (_, _) => bail!("invalid git-rev provided: {}", s),
        }
    }
}

impl<'a> GitSrc {
    pub(crate) fn toml_src_value(&'a self) -> ([&'a str; 2], &'a str) {
        match &self {
            GitSrc::Branch(branch) => (["src", "branch"], branch),
            GitSrc::Revision(id) => (["src", "manual"], id),
        }
    }

    pub(crate) fn is_rev(&'a self) -> bool {
        matches!(self, GitSrc::Revision(_))
    }
}

#[derive(serde::Serialize, serde::Deserialize, Debug, PartialEq)]
#[serde(rename_all = "camelCase")]
struct HolochainVersion {
    url: String,
    rev: String,
    sha256: String,
    cargo_lock: CargoLock,
    bins_filter: Vec<String>,

    lair: LairVersion,

    // these are only used to inform the template comment
    #[serde(skip)]
    args: Vec<String>,
}

#[derive(serde::Serialize, serde::Deserialize, Debug, PartialEq)]
#[serde(rename_all = "camelCase")]
struct LairVersion {
    url: String,
    rev: String,
    sha256: String,
    cargo_lock: CargoLock,
}

#[derive(serde::Serialize, serde::Deserialize, Debug, PartialEq)]
#[serde(rename_all = "camelCase")]
struct CargoLock {
    lock_file: Option<String>,
    output_hashes: HashMap<String, String>,
}

static HOLOCHAIN_VERSION_TEMPLATE: &str = "holochain_version_template";
static HOLOCHAIN_VERSIONS_TEMPLATE: &str = "holochain_versions_template";

static HANDLEBARS: Lazy<handlebars::Handlebars> = Lazy::new(|| {
    let mut handlebars = handlebars::Handlebars::new();
    handlebars
        .register_template_string(
            HOLOCHAIN_VERSION_TEMPLATE,
            r#"# This file was generated with the following command:
#{{#each this.args}} {{{@this}}}{{/each}}
# For usage instructions please visit https://github.com/holochain/holochain-nixpkgs/#readme

{
    url = "{{this.url}}";
    rev = "{{this.rev}}";
    sha256 = "{{{this.sha256}}}";
    cargoLock = {
        outputHashes = {
            {{#each this.cargoLock.outputHashes}}
            "{{@key}}" = "{{{@this}}}";
            {{/each}}
        };
    };

    binsFilter = [
        {{#each this.binsFilter}}
        "{{@this}}"
        {{/each}}
    ];

    lair = {
        url = "{{this.lair.url}}";
        rev = "{{this.lair.rev}}";
        sha256 = "{{{this.lair.sha256}}}";

        binsFilter = [
            "lair-keystore"
        ];

        cargoLock = {
            outputHashes = {
                {{#each this.lair.cargoLock.outputHashes}}
                "{{@key}}" = "{{{@this}}}";
                {{/each}}
            };
        };
    };
}
"#,
        )
        .unwrap();

    handlebars
        .register_template_string(
            HOLOCHAIN_VERSIONS_TEMPLATE,
            r#"
{
    {{#each holochain_version as |value key|}}
        {{@key}} = {{>holochain_version_template}};
    {{/each}}
}
"#,
        )
        .unwrap();

    handlebars
});

fn main() -> Fallible<()> {
    let opt = Opt::from_args();

    let nvfetcher_holochain = NvfetcherWrapper::new(
        BinCrateSource {
            name: "holochain",
            git_repo: &opt.git_repo,
            git_src: opt.git_src.clone(),
            bins_filter: opt.bins_filter.clone(),
        },
        opt.nvfetcher_dir.clone(),
        None,
    )?;

    let holochain_version = get_holochain_version(true, nvfetcher_holochain, opt.lair_version_req)?;

    let rendered_holochain_source = render_holochain_version(&holochain_version)?;
    std::fs::write(opt.output_file, rendered_holochain_source)?;

    Ok(())
}

fn get_holochain_version(
    update: bool,
    nvfetcher_holochain: NvfetcherWrapper,
    lair_version_req: semver::VersionReq,
) -> Fallible<HolochainVersion> {
    let holochain_crate_srcinfo = nvfetcher_holochain
        .get_crate_srcinfo(update)
        .context("get holochain crate srcinfo")?;

    let (lair_repo, lair_rev) =
        read_lair_revision(&nvfetcher_holochain, &lair_version_req).map(|(repo, rev)| {
            (
                // TODO: test this case and make the fallback configurable
                repo.map(|url| url.to_string())
                    .unwrap_or_else(|| "https://github.com/holochain/lair".to_string()),
                rev,
            )
        })?;

    let nvfetcher_lair = NvfetcherWrapper::new(
        BinCrateSource {
            name: "lair",
            git_repo: &lair_repo,
            git_src: GitSrc::Revision(lair_rev),
            bins_filter: Default::default(),
        },
        Some(nvfetcher_holochain.nvfetcher_dir),
        None,
    )
    .context("create nvfetchwrapper for lair")?;

    let lair_crate_srcinfo = nvfetcher_lair
        .get_crate_srcinfo(update)
        .context("get lair crate srcinfo")?;

    Ok(HolochainVersion {
        url: holochain_crate_srcinfo.src.url,
        rev: holochain_crate_srcinfo.src.rev,
        sha256: holochain_crate_srcinfo.src.sha256,
        bins_filter: nvfetcher_holochain.src.bins_filter,
        cargo_lock: CargoLock {
            // TODO: get the store path for the lockfile
            lock_file: None,
            output_hashes: holochain_crate_srcinfo.cargo_lock.output_hashes,
        },

        lair: LairVersion {
            url: lair_crate_srcinfo.src.url,
            rev: lair_crate_srcinfo.src.rev,
            sha256: lair_crate_srcinfo.src.sha256,
            cargo_lock: CargoLock {
                // TODO: get the store path for the lockfile
                lock_file: None,
                output_hashes: lair_crate_srcinfo.cargo_lock.output_hashes,
            },
        },

        args: std::env::args()
            .into_iter()
            .map(|arg| {
                arg.replace(
                    &format!(
                        "{}/",
                        std::env::current_dir()
                            .unwrap_or_default()
                            .to_string_lossy()
                    ),
                    "",
                )
            })
            .collect(),
    })
}

fn render_holochain_version(holochain_version: &HolochainVersion) -> Fallible<String> {
    eprintln!(
        "rendering holochain version information: {:#?}",
        holochain_version
    );

    let mut rendered_holochain_source = vec![];
    HANDLEBARS.render_to_write(
        HOLOCHAIN_VERSION_TEMPLATE,
        holochain_version,
        &mut rendered_holochain_source,
    )?;

    let string = String::from_utf8_lossy(&rendered_holochain_source).to_string();

    eprintln!("rendered source: {}", string);

    Ok(string)
}

// this reads the lair version from the holochain source directory's Cargo.lock
// TODO: simply read the lair version from the local Cargo.lock that nvfetcher stores?
fn read_lair_revision(
    nvfetcher_holochain: &NvfetcherWrapper,
    version_req: &semver::VersionReq,
) -> Fallible<(Option<Url>, String)> {
    let tmpdir = tempdir()?;

    let import_fn = r#"
{ generated ? ./_sources/generated.nix }:
let
  _nixpkgs = ((import <nixpkgs> {}).callPackage ./_sources/generated.nix { }).nixpkgs.src;
  nixpkgs = import _nixpkgs {};
in nixpkgs.callPackage generated {}
"#;
    let sources_fn_path = nvfetcher_holochain.nvfetcher_dir.join("sources.nix");
    std::fs::write(&sources_fn_path, import_fn)?;

    let holochain_generated_path = nvfetcher_holochain
        .nvfetcher_dir
        .join("_sources/generated.nix");
    let holochain_src_path = tmpdir.path().join("holochain_src_path");

    use cargo_lock::Lockfile;
    let mut src_path_cmd = Command::new("nix");

    src_path_cmd.args(&[
        "build",
        "-f",
        &sources_fn_path.to_string_lossy(),
        "--argstr",
        "generated",
        &holochain_generated_path.to_string_lossy(),
        "-o",
        &holochain_src_path.to_string_lossy(),
        &nvfetcher_holochain.src.crate_toml_key(),
    ]);

    eprintln!("running {:#?}", &src_path_cmd);

    let child = src_path_cmd.spawn()?;
    let output = child.wait_with_output()?;
    if !ExitStatus::success(&output.status) {
        bail!("{:?}", output);
    }

    let holochain_cargo_lock_path = holochain_src_path.join("Cargo.lock");

    let lockfile = Lockfile::load(&holochain_cargo_lock_path)?;
    eprintln!("number of dependencies: {}", lockfile.packages.len());

    let lair_keystore_api_dep = lockfile
        .packages
        .iter()
        .find(|p| p.name.as_str() == "lair_keystore_api" && version_req.matches(&p.version))
        .ok_or_else(|| {
            anyhow::anyhow!(
                "couldn't find lair_keystore_api matching '{}' in {:?}",
                &version_req,
                holochain_cargo_lock_path.display(),
            )
        })?;

    let lair_source = match &lair_keystore_api_dep.source {
        Some(source) if source.is_git() => {
            eprintln!("lair is a git source! {:#?}", source.url());
            let mut url = source.url().clone();
            if url
                .set_scheme(&source.url().scheme().replace("git+", ""))
                .is_err()
            {
                bail!("couldn't set scheme");
            }

            Some(url)
        }
        _ => None,
    };

    let lair_rev = format!("v{}", lair_keystore_api_dep.version);

    Ok((lair_source, lair_rev))
}

#[cfg(test)]
mod tests {
    use crate::{nvfetcher::nix_to_json_partial, *};
    use pretty_assertions::assert_eq;

    #[test]
    fn nvfetcher_generate_and_render() {
        let nvfetcher_dir = std::env::current_dir()
            .unwrap()
            .join("test/fixtures/nvfetcher_0/");

        let nvfetcher_holochain = NvfetcherWrapper::new(
            BinCrateSource {
                name: "holochain",
                git_repo: "https://github.com/holochain/holochain",
                git_src: GitSrc::Revision("holochain-0.0.121".to_string()),
                bins_filter: vec![
                    "holochain".to_string(),
                    "hc".to_string(),
                    "kitsune-p2p-proxy".to_string(),
                ],
            },
            Some(nvfetcher_dir),
            None,
        )
        .unwrap();

        let mut holochain_version = get_holochain_version(
            false,
            nvfetcher_holochain,
            semver::VersionReq::from_str("*").unwrap(),
        )
        .unwrap();

        holochain_version.args = Default::default();

        let rendered_holochain_source = render_holochain_version(&holochain_version).unwrap();
        let json_holochain_source =
            nix_to_json_partial(rendered_holochain_source.as_bytes()).unwrap();

        let deserialized_holochain_version =
            serde_json::from_value::<HolochainVersion>(json_holochain_source).unwrap();

        assert_eq!(holochain_version, deserialized_holochain_version);
    }
}

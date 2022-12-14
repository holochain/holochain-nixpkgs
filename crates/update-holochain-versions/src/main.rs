use anyhow::{bail, Context};
use once_cell::sync::Lazy;
use std::{
    collections::HashMap,
    path::{Path, PathBuf},
    process::{Command, ExitStatus},
};
use structopt::StructOpt;
use tempfile::tempdir;
use update_holochain_versions::{
    nvfetcher::{BinCrateSource, NvfetcherCrateSrcEntry, NvfetcherWrapper},
    update_config::{GitSrc, ToolingCompatibilitySpecV1, UpdateConfigEntry},
};
use url::Url;

type Fallible<T> = anyhow::Result<T>;

pub const DEFAULT_LAIR_GIT_REPO: &str = "https://github.com/holochain/lair";
pub const DEFAULT_SCAFFOLDING_GIT_REPO: &str = "https://github.com/holochain/scaffolding";
pub const DEFAULT_LAUNCHER_GIT_REPO: &str = "https://github.com/holochain/launcher";

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

    /// Specifier for the lair git repository
    #[structopt(long, default_value = DEFAULT_LAIR_GIT_REPO)]
    lair_git_repo: String,

    /// Specifier for the scaffolding git repository
    #[structopt(long, default_value = DEFAULT_SCAFFOLDING_GIT_REPO)]
    scaffolding_git_repo: String,

    /// Specifier for the launcher git repository
    #[structopt(long, default_value = DEFAULT_LAUNCHER_GIT_REPO)]
    launcher_git_repo: String,

    #[structopt(flatten)]
    update_config_entry: UpdateConfigEntry,
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

#[derive(serde::Serialize, serde::Deserialize, Debug, PartialEq)]
#[serde(rename_all = "camelCase")]
struct HolochainVersion {
    url: String,
    rev: String,
    sha256: String,
    cargo_lock: CargoLock,
    bins_filter: Vec<String>,
    rust_version: Option<semver::Version>,

    lair: ToolingVersion,
    scaffolding: Option<ToolingVersion>,
    launcher: Option<ToolingVersion>,

    // these are only used to inform the template comment
    #[serde(skip_serializing_if = "Vec::is_empty", default = "Default::default")]
    args: Vec<String>,
}

#[derive(serde::Serialize, serde::Deserialize, Debug, PartialEq)]
#[serde(rename_all = "camelCase")]
struct ToolingVersion {
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

    {{#if this.rustVersion}}
    rustVersion = "{{this.rustVersion}}";
    {{/if}}

    lair = {
        url = "{{this.lair.url}}";
        rev = "{{this.lair.rev}}";
        sha256 = "{{{this.lair.sha256}}}";

        binsFilter = [
            "lair-keystore"
        ];

        {{#if this.rustVersion}}
        rustVersion = "{{this.rustVersion}}";
        {{/if}}

        cargoLock = {
            outputHashes = {
                {{#each this.lair.cargoLock.outputHashes}}
                "{{@key}}" = "{{{@this}}}";
                {{/each}}
            };
        };
    };

    {{#if this.scaffolding}}
    scaffolding = {
        url = "{{this.scaffolding.url}}";
        rev = "{{this.scaffolding.rev}}";
        sha256 = "{{{this.scaffolding.sha256}}}";

        binsFilter = [
            "hc-scaffold"
        ];

        {{#if this.rustVersion}}
        rustVersion = "{{this.rustVersion}}";
        {{/if}}

        cargoLock = {
            outputHashes = {
                {{#each this.scaffolding.cargoLock.outputHashes}}
                "{{@key}}" = "{{{@this}}}";
                {{/each}}
            };
        };
    };
    {{/if}}

    {{#if this.launcher}}
    launcher = {
        url = "{{this.launcher.url}}";
        rev = "{{this.launcher.rev}}";
        sha256 = "{{{this.launcher.sha256}}}";

        binsFilter = [
            "hc-launch"
        ];

        {{#if this.rustVersion}}
        rustVersion = "{{this.rustVersion}}";
        {{/if}}

        cargoLock = {
            outputHashes = {
                {{#each this.launcher.cargoLock.outputHashes}}
                "{{@key}}" = "{{{@this}}}";
                {{/each}}
            };
        };
    };
    {{/if}}
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

    if opt.update_config_entry.broken.unwrap_or_default() {
        eprintln!("skipping update as `--broken=true` was passed.");
        return Ok(());
    }

    let nvfetcher_holochain = NvfetcherWrapper::new(
        BinCrateSource {
            name: "holochain",
            git_repo: &opt.git_repo,
            git_src: opt.update_config_entry.git_src.clone(),
            bins_filter: opt.update_config_entry.bins_filter.clone(),
        },
        opt.nvfetcher_dir.clone(),
        None,
    )?;

    let holochain_version = get_holochain_version(
        opt.update_config_entry.rust_version.clone(),
        true,
        nvfetcher_holochain,
        opt.update_config_entry.lair_version_req,
        opt.lair_git_repo,
        opt.update_config_entry
            .scaffolding_holochain_compatibility_version_req,
        opt.update_config_entry
            .launcher_holochain_compatibility_version_req,
    )?;

    let rendered_holochain_source = render_holochain_version(&holochain_version)?;
    std::fs::write(opt.output_file, rendered_holochain_source)?;

    Ok(())
}

fn get_holochain_version(
    rust_version: Option<semver::Version>,
    update: bool,
    nvfetcher_holochain: NvfetcherWrapper,
    lair_version_req: semver::VersionReq,
    lair_git_repo: String,
    scaffolding_compatibility: ToolingCompatibilitySpecV1,
    launcher_compatibility: ToolingCompatibilitySpecV1,
) -> Fallible<HolochainVersion> {
    let holochain_crate_srcinfo = nvfetcher_holochain
        .get_crate_srcinfo(update)
        .context("get holochain crate srcinfo")?;
    let holochain_semver = holochain_crate_srcinfo.semver()?;

    let (lair_repo, lair_rev) =
        read_lair_revision(&nvfetcher_holochain, &lair_version_req).map(|(repo, rev)| {
            (
                // TODO: test this case and make the fallback configurable
                repo.map(|url| url.to_string())
                    .unwrap_or_else(|| lair_git_repo),
                rev,
            )
        })?;

    let nvfetcher_lair = NvfetcherWrapper::new(
        BinCrateSource {
            // TODO: make this variable
            name: "lair",
            git_repo: &lair_repo,
            git_src: GitSrc::Revision(lair_rev),
            bins_filter: Default::default(),
        },
        Some(nvfetcher_holochain.nvfetcher_dir.clone()),
        None,
    )
    .context("create nvfetchwrapper for lair")?;

    let lair_crate_srcinfo = nvfetcher_lair
        .get_crate_srcinfo(update)
        .context("get lair crate srcinfo")?;

    let scaffolding_crate_srcinfo: Option<NvfetcherCrateSrcEntry> = if scaffolding_compatibility
        .holochain_version_req
        .matches(&holochain_semver)
    {
        todo!("");
        // TODO: loop to find the correct scaffolding
        /*
        let scaffolding_crate_srcinfo = match scaffolding_version_req {
            None => None,
            Some(v) => {
                // TODO: evaluate scaffolding version
                let nvfetcher_scaffolding = NvfetcherWrapper::new(
                    BinCrateSource {
                        name: "scaffolding",
                        git_repo: "https://github.com/holochain/scaffolding",
                        git_src: GitSrc::Revision(format!("v{}", v)),
                        bins_filter: Default::default(),
                    },
                    Some(nvfetcher_holochain.nvfetcher_dir),
                    None,
                )
                .context("create nvfetchwrapper for scaffolding")?;

                Some(
                    nvfetcher_scaffolding
                        .get_crate_srcinfo(update)
                        .context("get scaffolding crate srcinfo")?,
                )
            }
        };
         */
    } else {
        None
    };

    let launcher_crate_srcinfo: Option<NvfetcherCrateSrcEntry> = if launcher_compatibility
        .holochain_version_req
        .matches(&holochain_semver)
    {
        todo!("")
        // TODO: loop to find the correct launcher
    } else {
        None
    };

    let mut args = std::env::args()
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
        .collect::<Vec<_>>();

    if let Some(file_name) = args
        .get(0)
        .map(Path::new)
        .map(Path::file_name)
        .flatten()
        .map(|os| os.to_string_lossy().to_string())
    {
        args[0] = file_name;
    }

    Ok(HolochainVersion {
        url: holochain_crate_srcinfo.src.url,
        rev: holochain_crate_srcinfo.src.rev,
        sha256: holochain_crate_srcinfo.src.sha256,
        bins_filter: nvfetcher_holochain.src.bins_filter,
        rust_version,
        cargo_lock: CargoLock {
            // TODO: get the store path for the lockfile
            lock_file: None,
            output_hashes: holochain_crate_srcinfo.rust_git_deps,
        },

        lair: ToolingVersion {
            url: lair_crate_srcinfo.src.url,
            rev: lair_crate_srcinfo.src.rev,
            sha256: lair_crate_srcinfo.src.sha256,
            cargo_lock: CargoLock {
                // TODO: get the store path for the lockfile
                lock_file: None,
                output_hashes: lair_crate_srcinfo.rust_git_deps,
            },
        },

        scaffolding: scaffolding_crate_srcinfo.map(|info| ToolingVersion {
            url: info.src.url,
            rev: info.src.rev,
            sha256: info.src.sha256,
            cargo_lock: CargoLock {
                // TODO: get the store path for the lockfile
                lock_file: None,
                output_hashes: info.rust_git_deps,
            },
        }),

        launcher: launcher_crate_srcinfo.map(|info| ToolingVersion {
            url: info.src.url,
            rev: info.src.rev,
            sha256: info.src.sha256,
            cargo_lock: CargoLock {
                // TODO: get the store path for the lockfile
                lock_file: None,
                output_hashes: info.rust_git_deps,
            },
        }),

        args,
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
  _nixpkgs = (import ./_sources/generated.nix {
    fetchgit = null;
    fetchurl = null;
    fetchFromGitHub = null;
  }).nixpkgs.src;
  nixpkgs = import _nixpkgs { };
in
nixpkgs.callPackage generated { }
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

    const PACKAGE_OF_INTEREST: &str = "lair_keystore_api";

    let package = lockfile
        .packages
        .iter()
        .find(|p| p.name.as_str() == PACKAGE_OF_INTEREST && version_req.matches(&p.version))
        .ok_or_else(|| {
            anyhow::anyhow!(
                "couldn't find {} matching '{}' in {:?}",
                PACKAGE_OF_INTEREST,
                &version_req,
                holochain_cargo_lock_path.display(),
            )
        })?;

    let lair_source = match &package.source {
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

    // starting with 0.1.2 we need to prefix the crate name
    let prefix = if package.version >= cargo_lock::Version::new(0, 1, 2) {
        format!("{}-", PACKAGE_OF_INTEREST)
    } else {
        Default::default()
    };

    let lair_rev = format!("{}v{}", prefix, package.version);

    Ok((lair_source, lair_rev))
}

#[cfg(test)]
mod tests {
    use std::str::FromStr;

    use pretty_assertions::assert_eq;
    use update_holochain_versions::{
        nix_to_json_partial, nvfetcher::NvfetcherWrapper, update_config::ToolingCompatibilitySpecV1,
    };

    use crate::{
        get_holochain_version, render_holochain_version, BinCrateSource, GitSrc, HolochainVersion,
        DEFAULT_LAIR_GIT_REPO, DEFAULT_SCAFFOLDING_GIT_REPO,
    };

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
            None,
            false,
            nvfetcher_holochain,
            semver::VersionReq::from_str("*").unwrap(),
            DEFAULT_LAIR_GIT_REPO.to_string(),
            update_holochain_versions::update_config::default_scaffolding_holochain_compatibility_version_req(),
            update_holochain_versions::update_config::default_launcher_holochain_compatibility_version_req(),
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

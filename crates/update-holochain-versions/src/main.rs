use anyhow::{bail, Context};
use cargo::core::dependency::DepKind;
use common::git_helper;
use once_cell::sync::Lazy;
use semver::{Version, VersionReq};
use std::{
    collections::HashMap,
    path::{Path, PathBuf},
};
use structopt::StructOpt;
use update_holochain_versions::{
    nvfetcher::{BinCrateSource, NvfetcherCrateSrcEntry, NvfetcherWrapper},
    update_config::{GitSrc, ToolingCompatibilitySpecV1, UpdateConfigEntry},
};
use url::Url;

type Fallible<T> = anyhow::Result<T>;

pub const DEFAULT_LAIR_GIT_REPO: &str = "https://github.com/holochain/lair";

pub const DEFAULT_SCAFFOLDING_GIT_REPO: &str = "https://github.com/holochain/scaffolding";
pub const DEFAULT_SCAFFOLDING_CRATE_NAME: &str = "holochain_scaffolding_cli";

pub const DEFAULT_LAUNCHER_GIT_REPO: &str = "https://github.com/holochain/launcher";
pub const DEFAULT_LAUNCHER_CRATE_NAME: &str = "holochain_cli_launch";

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

#[tokio::main]
async fn main() -> Fallible<()> {
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
        opt.scaffolding_git_repo,
        opt.update_config_entry
            .launcher_holochain_compatibility_version_req,
        opt.launcher_git_repo,
    )
    .await?;

    let rendered_holochain_source = render_holochain_version(&holochain_version)?;
    std::fs::write(opt.output_file, rendered_holochain_source)?;

    Ok(())
}

async fn get_holochain_version<'a>(
    rust_version: Option<semver::Version>,
    update: bool,
    nvfetcher_holochain: NvfetcherWrapper<'a>,
    lair_version_req: semver::VersionReq,
    lair_git_repo: String,
    scaffolding_compatibility: ToolingCompatibilitySpecV1,
    scaffolding_git_repo: String,
    launcher_compatibility: ToolingCompatibilitySpecV1,
    launcher_git_repo: String,
) -> Fallible<HolochainVersion> {
    let holochain_crate_srcinfo = nvfetcher_holochain
        .get_crate_srcinfo(update)
        .context("get holochain crate srcinfo")?;

    let holochain_semver = holochain_crate_srcinfo.semver()?;

    let (lair_repo, lair_rev) = {
        read_lair_revision(&nvfetcher_holochain, &lair_version_req).map(|(repo, rev)| {
            (
                // TODO: test this case and make the fallback configurable
                repo.map(|url| url.to_string())
                    .unwrap_or_else(|| lair_git_repo),
                rev,
            )
        })?
    };

    let lair_crate_srcinfo = NvfetcherWrapper::new(
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
    .context("create nvfetchwrapper for lair")?
    .get_crate_srcinfo(update)
    .context("get lair crate srcinfo")?;

    let scaffolding_crate_srcinfo: Option<NvfetcherCrateSrcEntry> =
        maybe_get_tooling_crate_srcinfo(
            &nvfetcher_holochain,
            &holochain_semver,
            scaffolding_compatibility,
            &scaffolding_git_repo,
            DEFAULT_SCAFFOLDING_CRATE_NAME,
            vec!["hc-scaffold".to_string()],
        )
        .await?;

    let launcher_crate_srcinfo: Option<NvfetcherCrateSrcEntry> = maybe_get_tooling_crate_srcinfo(
        &nvfetcher_holochain,
        &holochain_semver,
        launcher_compatibility,
        &launcher_git_repo,
        DEFAULT_LAUNCHER_CRATE_NAME,
        vec!["hc-launch".to_string()],
    )
    .await?;

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
                lock_file: Some(info.cargo_lock),
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
    let (holochain_cargo_lock_path, _) = nvfetcher_holochain.get_src_file("Cargo.lock")?;
    let lockfile = cargo_lock::Lockfile::load(&holochain_cargo_lock_path)?;
    eprintln!("number of dependencies: {}", lockfile.packages.len());

    const PACKAGE_OF_INTEREST: &str = "lair_keystore_api";

    let package = lockfile
        .packages
        .iter()
        .find(|p| {
            p.name.as_str() == PACKAGE_OF_INTEREST && {
                let is_semver_match = version_req.matches(&p.version);
                eprintln!(
                    "[DEBUG]] {} ~ {} => {}",
                    version_req, &p.version, is_semver_match
                );

                is_semver_match
            }
        })
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

async fn maybe_get_tooling_crate_srcinfo<'a>(
    nvfetcher_holochain: &NvfetcherWrapper<'a>,
    holochain_semver: &semver::Version,
    tooling_compatibility: ToolingCompatibilitySpecV1,
    tooling_git_repo: &str,
    tooling_crate_name: &str,
    tooling_bins_filter: Vec<String>,
) -> Fallible<Option<NvfetcherCrateSrcEntry>> {
    if tooling_compatibility
        .holochain_version_req
        .matches(holochain_semver)
    {
        // TODO: make the glob_filter configurable

        let mut nvfetcher_wrapper_final: Option<(semver::Version, NvfetcherWrapper)> =
            Default::default();

        let remote_tags =
            git_helper::ls_remote_tags(&tooling_git_repo, &format!("{}-*", tooling_crate_name))
                .await?;

        for tag in remote_tags {
            let scaffolding_nvfetcher_wrapper = NvfetcherWrapper::new(
                BinCrateSource {
                    name: tooling_crate_name,
                    git_repo: &tooling_git_repo,
                    // TODO: support branches in addition to tags
                    git_src: GitSrc::Revision(tag.clone()),
                    // TODO: make this variable
                    bins_filter: tooling_bins_filter.clone(),
                },
                Some(nvfetcher_holochain.nvfetcher_dir.clone()),
                None,
            )
            .context(format!("create nvfetchwrapper for {}", tag))?;

            let src_path = scaffolding_nvfetcher_wrapper.get_src_path()?;

            let config = cargo::util::config::Config::default()?;
            let cargo_workspace =
                cargo::core::Workspace::new(&src_path.join("Cargo.toml"), &config)?;

            let crt = cargo_workspace
                .members()
                .find(|member| member.name().to_string() == tooling_crate_name)
                .ok_or_else(|| {
                    anyhow::anyhow!(
                        "couldn't find {} in workspace at {:?}",
                        tooling_crate_name,
                        src_path
                    )
                })?;
            let tooling_semver = crt.version();

            fn is_star_or_matches<F>(
                version: &Version,
                version_req: &VersionReq,
                debug: F,
            ) -> Fallible<bool>
            where
                F: FnOnce((&Version, &VersionReq, bool, bool, bool)) -> (),
            {
                let is_star = version_req == &semver::VersionReq::STAR;
                let is_specific_match = version_req.matches(&version);
                let result = is_star || is_specific_match;

                debug((version, version_req, is_star, is_specific_match, result));

                Ok(result)
            }

            if !is_star_or_matches(
                &tooling_semver,
                &tooling_compatibility.tool_version_req,
                |(version, version_req, is_star, is_specific_match, result)| {
                    let name = &format!("{}-{}", crt.name(), crt.version());
                    eprintln!(
                        "[DEBUG]: is_star {}, is_specific_match: ({} ~ {}) {}. skip {} at tag {}? {}",
                        is_star, version_req, version, is_specific_match, name, tag, !result
                    );
                },
            )? {
                continue;
            }

            let holochain_version_reqs = crt
                .dependencies()
                .iter()
                .find_map(|dep| {
                    if dep.kind() == DepKind::Normal {
                        if dep.package_name() == "holochain" {
                            Some(dep.version_req())
                        } else {
                            None
                        }
                    } else {
                        eprintln!("WARN: ignoring {:?} dependency on holochain", dep.kind());
                        None
                    }
                })
                .ok_or_else(|| anyhow::anyhow!("holochain is not a dependency of {:?}", crt))?;

            if is_star_or_matches(
                holochain_semver,
                &VersionReq::parse(&holochain_version_reqs.to_string())?,
                |_| {},
            )? {
                eprint!(
                    "[DEBUG] deciding between candidate {} ({:?}) and {:?} ({:?}) => ",
                    tooling_semver.to_string(),
                    &tooling_semver,
                    nvfetcher_wrapper_final
                        .as_ref()
                        .map(|(a, b)| (a.to_string(), b)),
                    &nvfetcher_wrapper_final,
                );

                nvfetcher_wrapper_final = match nvfetcher_wrapper_final {
                    Some((existing_version, existing_wrapper))
                        if tooling_semver < &existing_version =>
                    {
                        Some((existing_version, existing_wrapper))
                    }
                    _ => Some((tooling_semver.clone(), scaffolding_nvfetcher_wrapper)),
                };
                eprintln!("{:?}", &nvfetcher_wrapper_final);
            }
        }
        nvfetcher_wrapper_final
            .map(|(_, nvfetcher_wrapper)| nvfetcher_wrapper.get_crate_srcinfo(false))
            .transpose()
    } else {
        eprintln!(
            "[DEBUG]: tooling_compatibility.holochain_version_req {} doesn't match holochain_semver {}",
            tooling_compatibility.holochain_version_req.to_string(),
            holochain_semver.to_string()
        );

        Ok(None)
    }
}

#[cfg(test)]
mod tests {
    use std::str::FromStr;

    use pretty_assertions::assert_eq;
    use update_holochain_versions::{nix_to_json_partial, nvfetcher::NvfetcherWrapper};

    use crate::{
        get_holochain_version, render_holochain_version, BinCrateSource, GitSrc, HolochainVersion,
        DEFAULT_LAIR_GIT_REPO, DEFAULT_LAUNCHER_GIT_REPO, DEFAULT_SCAFFOLDING_GIT_REPO,
    };

    #[tokio::test]
    async fn nvfetcher_generate_and_render() {
        std::env::set_var("NVFETCHER_FORCE_OFFLINE", "true");

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
            DEFAULT_SCAFFOLDING_GIT_REPO.to_string(),
            update_holochain_versions::update_config::default_launcher_holochain_compatibility_version_req(),
            DEFAULT_LAUNCHER_GIT_REPO.to_string(),
        ).await
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

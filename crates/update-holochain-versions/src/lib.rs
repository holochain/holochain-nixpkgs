use anyhow::Context;

pub mod nvfetcher;

/// performs an incomplete conversion from Nix to JSON5 code.
pub fn nix_to_json_partial<R: std::io::Read>(mut input: R) -> anyhow::Result<serde_json::Value> {
    let mut buf = String::new();
    input.read_to_string(&mut buf)?;
    let output = buf.clone();

    let output = regex::Regex::new(r"\{ (fetch.+,?)+ }:")
        .unwrap()
        .replace_all(&output, r#""#);

    let output = regex::Regex::new(r"(?m)^#(\w|.)*\n")
        .unwrap()
        .replace_all(&output, r#""#);

    let output = regex::Regex::new(r"(?P<key>(_|-|\w)+) = ")
        .unwrap()
        .replace_all(&output, r#""${key}" = "#);

    let output = regex::Regex::new(r#"" = "#)
        .unwrap()
        .replace_all(&output, r#"": "#);

    let output = regex::Regex::new(r"fetch(url|FromGitHub|git|Tarball) \(?\{")
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

    // add commas to list entries
    let output = regex::Regex::new(r#""\s*\n"#)
        .unwrap()
        .replace_all(&output, r#"", "#);

    let json: serde_json::Value =
        json5::from_str(&output).context(format!("converted this nix expression:\n{}\nto this json5:\n{}\nand failed to parse the json5 as such.", &buf, &output))?;

    Ok(json)
}

/// types for the update_config.toml file
pub mod update_config {
    use std::str::FromStr;

    use anyhow::bail;
    use once_cell::sync::Lazy;
    use semver::VersionReq;
    use serde::{Deserialize, Serialize};
    use structopt::StructOpt;

    const DEFAULT_BINS_FILTER: &str = "holochain,hc,kitsune-p2p-proxy,kitsune-p2p-tx2-proxy";
    pub fn default_bins_filter() -> Vec<String> {
        DEFAULT_BINS_FILTER
            .split(",")
            .map(ToString::to_string)
            .collect()
    }

    const DEFAULT_LAIR_VERSION_REQ: &str = "~0.2";
    pub fn default_lair_version_req() -> semver::VersionReq {
        semver::VersionReq::from_str(DEFAULT_LAIR_VERSION_REQ).unwrap()
    }

    #[derive(Debug, Serialize, Deserialize, smart_default::SmartDefault)]
    pub struct ToolingCompatibilitySpecV1 {
        pub holochain_version_req: VersionReq,
        pub tool_version_req: VersionReq,
    }

    impl FromStr for ToolingCompatibilitySpecV1 {
        type Err = serde_json::Error;

        fn from_str(s: &str) -> Result<Self, Self::Err> {
            serde_json::from_str(s)
        }
    }

    pub static DEFAULT_SCAFFOLDING_HOLOCHAIN_COMPATIBILITY_VERSION_REQ: Lazy<String> =
        Lazy::new(|| {
            serde_json::to_string(&default_launcher_holochain_compatibility_version_req())
                .expect("JSON should deserialize")
        });
    pub fn default_scaffolding_holochain_compatibility_version_req() -> ToolingCompatibilitySpecV1 {
        ToolingCompatibilitySpecV1 {
            holochain_version_req: semver::VersionReq::from_str(">0.1.0-alpha, <2")
                .expect("default should parse"),
            tool_version_req: semver::VersionReq::STAR,
        }
    }

    pub static DEFAULT_LAUNCHER_HOLOCHAIN_COMPATIBILITY_VERSION_REQ: Lazy<String> =
        Lazy::new(|| {
            serde_json::to_string(&default_launcher_holochain_compatibility_version_req())
                .expect("JSON should deserialize")
        });

    pub fn default_launcher_holochain_compatibility_version_req() -> ToolingCompatibilitySpecV1 {
        ToolingCompatibilitySpecV1 {
            holochain_version_req: semver::VersionReq::from_str(">0.1.0-alpha, <2")
                .expect("default should parse"),
            tool_version_req: semver::VersionReq::STAR,
        }
    }

    /// type for entries in the update_config.toml file
    #[derive(Serialize, Deserialize, Debug, StructOpt, smart_default::SmartDefault)]
    #[serde(rename_all = "kebab-case")]
    pub struct UpdateConfigEntry {
        /// Specifier for the lair version requirement
        #[structopt(long, default_value = DEFAULT_LAIR_VERSION_REQ)]
        #[serde(default = "default_lair_version_req")]
        #[default(_code = "default_lair_version_req()")]
        pub lair_version_req: semver::VersionReq,

        /// specifies a map that will be used for which holochain versions it will be attempted to find a matching scaffolding version.
        /// we can't generally assume that a matching scaffolding is available for any given version,
        #[structopt(long, default_value = &DEFAULT_SCAFFOLDING_HOLOCHAIN_COMPATIBILITY_VERSION_REQ)]
        #[serde(default = "default_scaffolding_holochain_compatibility_version_req")]
        #[default(_code = "default_scaffolding_holochain_compatibility_version_req()")]
        #[serde(skip_serializing)]
        pub scaffolding_holochain_compatibility_version_req: ToolingCompatibilitySpecV1,

        /// specifies a map that will be used for which holochain versions it will be attempted to find a matching launcher version.
        /// we can't generally assume that a matching launcher is available for any given version,
        #[structopt(long, default_value = &DEFAULT_LAUNCHER_HOLOCHAIN_COMPATIBILITY_VERSION_REQ)]
        #[serde(default = "default_launcher_holochain_compatibility_version_req")]
        #[default(_code = "default_launcher_holochain_compatibility_version_req()")]
        #[serde(skip_serializing)]
        pub launcher_holochain_compatibility_version_req: ToolingCompatibilitySpecV1,

        #[structopt(
            long,
            default_value = DEFAULT_BINS_FILTER,
            use_delimiter = true
        )]
        #[serde(default = "default_bins_filter")]
        #[default(_code = "default_bins_filter()")]
        pub bins_filter: Vec<String>,

        #[structopt(long)]
        pub rust_version: Option<semver::Version>,

        /// indicates if this version is broken and will not lead to any file generation
        #[structopt(long)]
        pub broken: Option<bool>,

        /// Git source specifier for fetching the holochain sources.
        /// Either: branch:<branch_name> or revision:<rev>
        #[structopt(long)]
        pub git_src: GitSrc,
    }

    #[derive(Clone, Debug)]
    pub enum GitSrc {
        Branch(String),
        Revision(String),
    }

    impl<'de> Deserialize<'de> for GitSrc {
        fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
        where
            D: serde::Deserializer<'de>,
        {
            use serde::de::Error;

            let s: String = Deserialize::deserialize(deserializer)?;

            Self::from_str(&s).map_err(|e| -> <D as serde::Deserializer>::Error {
                D::Error::invalid_value(serde::de::Unexpected::Str(&s), &format!("{}", e).as_str())
            })
        }
    }

    impl Serialize for GitSrc {
        fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
        where
            S: serde::Serializer,
        {
            let s = self.to_string();
            serializer.serialize_str(&s)
        }
    }

    impl Default for GitSrc {
        fn default() -> Self {
            Self::Branch("main".to_string())
        }
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
        pub fn toml_src_value(&'a self) -> ([&'a str; 2], &'a str) {
            match &self {
                GitSrc::Branch(branch) => (["src", "branch"], branch),
                GitSrc::Revision(id) => (["src", "manual"], id),
            }
        }

        pub fn is_rev(&'a self) -> bool {
            matches!(self, GitSrc::Revision(_))
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn nix_to_json_partial_bug0() {
        let input = r#"
# This file was generated with the following command:
# /Users/stefan/src/holo/holochain-nixpkgs/target/debug/deps/update_holochain_versions-1d3ec227374761bd
# For usage instructions please visit https://github.com/holochain/holochain-nixpkgs/#readme

{
    url = "https://github.com/holochain/holochain";
    rev = "holochain-0.0.121";
    sha256 = "sha256-nZEySolvpXnTz9XlR+34rn6GJM/sj3y3snqhNGvmMkM&#x3D;";
    cargoLock = {
        outputHashes = {
            "cargo-test-macro-0.1.0" = "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs&#x3D;";
        };
    };

    binsFilter = [
        "holochain"
        "hc"
        "kitsune-p2p-proxy"
    ];
}
        "#;

        let _ = nix_to_json_partial(input.as_bytes())
            .unwrap()
            .as_object()
            .unwrap();
    }
}

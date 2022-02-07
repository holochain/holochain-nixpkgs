use anyhow::Context;

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

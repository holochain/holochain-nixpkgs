# This file was generated with the following command:
# update-holochain-versions --nvfetcher-dir=nix/nvfetcher --output-file=packages/holochain/versions/main.nix --git-src=branch:main
# For usage instructions please visit https://github.com/holochain/holochain-nixpkgs/#readme

{
    url = "https://github.com/holochain/holochain";
    rev = "1767dfc2d73ed107ac20dddc3fa56e46856c45cd";
    sha256 = "sha256-xhAzh+/bUgqxXuy8aVA0uvkb+28wJ7LiyoswguP4JIQ=";
    cargoLock = {
        outputHashes = {
            "cargo-test-macro-0.1.0" = "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs=";
        };
    };

    binsFilter = [
        "holochain"
        "hc"
        "kitsune-p2p-proxy"
    ];

    lair = {
        url = "https://github.com/holochain/lair";
        rev = "v0.0.9";
        sha256 = "sha256-glSixh2GtWtJ1wswAA0Q2hnLIFPQY+Tsh36IcUgIbRs=";

        binsFilter = [
            "lair-keystore"
        ];

        cargoLock = {
            outputHashes = {
            };
        };
    };
}

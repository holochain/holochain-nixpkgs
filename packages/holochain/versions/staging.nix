# This file was generated with the following command:
# update-holochain-versions --nvfetcher-dir=nix/nvfetcher --output-file=packages/holochain/versions/staging.nix --git-src=branch:staging
# For usage instructions please visit https://github.com/holochain/holochain-nixpkgs/#readme

{
    url = "https://github.com/holochain/holochain";
    rev = "8be9fcb86655fe6edc50abeb5b52d6116906c364";
    sha256 = "sha256-WApRUTphA4RWaw2GPZT+yJx+J8AVzOgfH5jkcQflfRw=";
    cargoLock = {
        outputHashes = {
        };
    };

    binsFilter = [
        "holochain"
        "hc"
        "kitsune-p2p-proxy"
    ];

    rustVersion = "1.58.1";

    lair = {
        url = "https://github.com/holochain/lair";
        rev = "v0.0.9";
        sha256 = "sha256-glSixh2GtWtJ1wswAA0Q2hnLIFPQY+Tsh36IcUgIbRs=";

        binsFilter = [
            "lair-keystore"
        ];

        rustVersion = "1.58.1";

        cargoLock = {
            outputHashes = {
            };
        };
    };
}

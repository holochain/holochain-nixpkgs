# This file was generated with the following command:
# update-holochain-versions --nvfetcher-dir=nix/nvfetcher --output-file=packages/holochain/versions/main.nix --git-src=branch:main
# For usage instructions please visit https://github.com/holochain/holochain-nixpkgs/#readme

{
    url = "https://github.com/holochain/holochain";
    rev = "9184f5c210376d50d6f2bc0632a2d06549d79bf3";
    sha256 = "sha256-9jUxpwjKtQc9nnaFKwGC8SUlJ9hMRkdi1B40cwRc/rQ=";
    cargoLock = {
        outputHashes = {
        };
    };

    binsFilter = [
        "holochain"
        "hc"
        "kitsune-p2p-proxy"
        "kitsune-p2p-tx2-proxy"
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

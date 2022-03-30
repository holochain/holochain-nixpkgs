# This file was generated with the following command:
# update-holochain-versions --nvfetcher-dir=nix/nvfetcher --output-file=packages/holochain/versions/develop.nix --git-src=branch:develop
# For usage instructions please visit https://github.com/holochain/holochain-nixpkgs/#readme

{
    url = "https://github.com/holochain/holochain";
    rev = "6af9da4a9a4275c0920bb071ebda4ee2836a8f13";
    sha256 = "sha256-nJ/SrPUhUEX9bHGbP4tGo9ZPocR8GZxUfpJgy2Lo74s=";
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

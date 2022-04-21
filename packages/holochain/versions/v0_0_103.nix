# This file was generated with the following command:
# update-holochain-versions --nvfetcher-dir=nix/nvfetcher --output-file=packages/holochain/versions/v0_0_103.nix --bins-filter=holochain,hc,kitsune-p2p-proxy,kitsune-p2p-tx2-proxy --git-src=revision:holochain-0.0.103 --lair-version-req=~0.0
# For usage instructions please visit https://github.com/holochain/holochain-nixpkgs/#readme

{
    url = "https://github.com/holochain/holochain";
    rev = "holochain-0.0.103";
    sha256 = "sha256-p9E1It1iZIsb8gntDljZcU3bL/BnkvwY2Y4JGegKHvw=";
    cargoLock = {
        outputHashes = {
            "cargo-test-macro-0.1.0" = "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs=";
        };
    };

    binsFilter = [
        "holochain"
        "hc"
        "kitsune-p2p-proxy"
        "kitsune-p2p-tx2-proxy"
    ];


    lair = {
        url = "https://github.com/holochain/lair";
        rev = "v0.0.3";
        sha256 = "sha256-EKuxixeCPhvkwv8Fq5+S2GNt59FEeBrgGHB50oJPP8o=";

        binsFilter = [
            "lair-keystore"
        ];


        cargoLock = {
            outputHashes = {
            };
        };
    };
}

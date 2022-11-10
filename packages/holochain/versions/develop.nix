# This file was generated with the following command:
# update-holochain-versions --nvfetcher-dir=nix/nvfetcher --output-file=packages/holochain/versions/develop.nix --bins-filter=holochain,hc,kitsune-p2p-proxy,kitsune-p2p-tx2-proxy --git-src=branch:develop --lair-version-req=~0.2
# For usage instructions please visit https://github.com/holochain/holochain-nixpkgs/#readme

{
    url = "https://github.com/holochain/holochain";
    rev = "3e1c4c64b843b9e5241d7e15922e1fa30fd6e720";
    sha256 = "sha256-b6vrOeill0SVLzvN0+Yj7FUJtsL/epwxAd8v5q6TjhE=";
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


    lair = {
        url = "https://github.com/holochain/lair";
        rev = "lair_keystore_api-v0.2.2";
        sha256 = "sha256-flRc+bm4jMKa5oLOTC+v1hleAgLeRIagStEP7qm5As4=";

        binsFilter = [
            "lair-keystore"
        ];


        cargoLock = {
            outputHashes = {
            };
        };
    };
}

# This file was generated with the following command:
# update-holochain-versions --nvfetcher-dir=nix/nvfetcher --output-file=packages/holochain/versions/develop_lair_0_1.nix --bins-filter=holochain,hc,kitsune-p2p-proxy,kitsune-p2p-tx2-proxy --git-src=branch:develop --lair-version-req=~0.1
# For usage instructions please visit https://github.com/holochain/holochain-nixpkgs/#readme

{
    url = "https://github.com/holochain/holochain";
    rev = "c0d982ad7f4253aca85f27a252346a52ce1d8e1d";
    sha256 = "sha256-ZF7V8ptkcGXBAXmwUNt4jqdIoazx6eKR6CdmHHDksVM=";
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
        rev = "v0.1.0";
        sha256 = "sha256-EWtc9+KcN/RHOg5N4wCLBXRppXheda5uubwrQVojc0s=";

        binsFilter = [
            "lair-keystore"
        ];


        cargoLock = {
            outputHashes = {
            };
        };
    };
}

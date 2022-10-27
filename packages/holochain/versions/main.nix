# This file was generated with the following command:
# update-holochain-versions --nvfetcher-dir=nix/nvfetcher --output-file=packages/holochain/versions/main.nix --bins-filter=holochain,hc,kitsune-p2p-proxy,kitsune-p2p-tx2-proxy --git-src=branch:main --lair-version-req=~0.2
# For usage instructions please visit https://github.com/holochain/holochain-nixpkgs/#readme

{
    url = "https://github.com/holochain/holochain";
    rev = "841a38e3e1a5b9368712e61a80d6f29e7eb2c310";
    sha256 = "sha256-O5ieU54YH3M3Rl/0XT9YKomn1NRDTmypB3Nq2WuIjAA=";
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
        rev = "lair_keystore_api-v0.2.1";
        sha256 = "sha256-ty5gGI9XIZJwV/kZ9DUpjbR2oneJpJVsmYgHLEnV+18=";

        binsFilter = [
            "lair-keystore"
        ];


        cargoLock = {
            outputHashes = {
            };
        };
    };
}

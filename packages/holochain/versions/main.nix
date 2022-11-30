# This file was generated with the following command:
# update-holochain-versions --nvfetcher-dir=nix/nvfetcher --output-file=packages/holochain/versions/main.nix --bins-filter=holochain,hc,kitsune-p2p-proxy,kitsune-p2p-tx2-proxy --git-src=branch:main --lair-version-req=~0.2
# For usage instructions please visit https://github.com/holochain/holochain-nixpkgs/#readme

{
    url = "https://github.com/holochain/holochain";
    rev = "64286bf7aa10e9e93032361a69843daa354fdb1b";
    sha256 = "sha256-CSQUKjZKKwFhWtwZcB9bKZCTBVxlD5Bfikw8cTHzTDY=";
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

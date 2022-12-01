# This file was generated with the following command:
# update-holochain-versions --git-src=revision:holochain-0.0.175 --lair-version-req=~0.2 --output-file=holochain_version.nix --scaffolding-version=0.0.5
# For usage instructions please visit https://github.com/holochain/holochain-nixpkgs/#readme

{
    url = "https://github.com/holochain/holochain";
    rev = "holochain-0.0.175";
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

    scaffolding = {
        url = "https://github.com/holochain/scaffolding";
        rev = "v0.0.5";
        sha256 = "sha256-rD/50Y9lj6orY5iWIFHdzkhlXJUL/X7pSh9t+Pju/FQ=";

        binsFilter = [
            "hc-scaffold"
        ];


        cargoLock = {
            outputHashes = {
            };
        };
    };
}

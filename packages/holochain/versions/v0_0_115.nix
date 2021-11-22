# This file was generated with the following command:
# /nix/store/445z7l0d39ncx5i3nwwpb4wlxy9hg2b5-update-holochain-versions/bin/update-holochain-versions --nvfetcher-dir=nix/nvfetcher --output-file=packages/holochain/versions/v0_0_115.nix --git-src=revision:holochain-0.0.115 --lair-version-req=~0.0
# For usage instructions please visit https://github.com/holochain/holochain-nixpkgs/#readme

{
    url = "https://github.com/holochain/holochain";
    rev = "holochain-0.0.115";
    sha256 = "163fvii27wqpni7f5f0m0nxivjjdgsycb2pnd1jcadx9i9d70ziv";
    cargoLock = {
        outputHashes = {
            "cargo-test-macro-0.1.0" = "1yy1y1d523xdzwg1gc77pigbcwsbawmy4b7vw8v21m7q957sk0c4";
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
        sha256 = "06vd1147323yhznf8qyhachcn6fs206h0c0bsx4npdc63p3a4m42";

        binsFilter = [
            "lair-keystore"
        ];

        cargoLock = {
            outputHashes = {
            };
        };
    };
}

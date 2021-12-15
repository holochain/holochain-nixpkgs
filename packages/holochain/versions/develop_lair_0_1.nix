# This file was generated with the following command:
# /nix/store/k1zr5azjx7rihn84xp8698kq59rjfvsj-update-holochain-versions/bin/update-holochain-versions --nvfetcher-dir=nix/nvfetcher --output-file=packages/holochain/versions/develop_lair_0_1.nix --git-src=branch:develop --lair-version-req=~0.1
# For usage instructions please visit https://github.com/holochain/holochain-nixpkgs/#readme

{
    url = "https://github.com/holochain/holochain";
    rev = "f96aec3bab0c8116b7d333714b995b9124d92b04";
    sha256 = "0yhgp24labxiqkfm2ky8bwji1n9ms93k0mvbyb48jbscnsqm9vcy";
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
        rev = "v0.1.0";
        sha256 = "0jvk4dd42axwp5pawxayg2jnjx05ic0f6k8f793z8dwwwbvmqsqi";

        binsFilter = [
            "lair-keystore"
        ];

        cargoLock = {
            outputHashes = {
            };
        };
    };
}

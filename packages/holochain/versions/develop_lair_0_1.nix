# This file was generated with the following command:
# /nix/store/445z7l0d39ncx5i3nwwpb4wlxy9hg2b5-update-holochain-versions/bin/update-holochain-versions --nvfetcher-dir=nix/nvfetcher --output-file=packages/holochain/versions/develop_lair_0_1.nix --git-src=branch:develop --lair-version-req=~0.1
# For usage instructions please visit https://github.com/holochain/holochain-nixpkgs/#readme

{
    url = "https://github.com/holochain/holochain";
    rev = "81711001e16a0f69e6bcf47e246f39f458b48ebe";
    sha256 = "11v3rxf1yi0armnwqh12alhcqf9h0ajfbg7irz5yx7v255s8lg83";
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

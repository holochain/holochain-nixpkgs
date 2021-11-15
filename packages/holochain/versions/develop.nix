# This file was generated.
# TODO: add comment at the top how to generate the file or how it was generated

{
    url = "https://github.com/holochain/holochain";
    rev = "77ea93f5155d1fb9ec34e4f60c4f0adc08df5e6e";
    sha256 = "05pzgxlph5wj4qr8lvyyf01gnvra0xg4f2mrfrirkip9qf3kjpi6";
    cargoLock = {
        # lockFile = "";
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
            # lockFile = "";
            outputHashes = {
            };
        };
    };
}
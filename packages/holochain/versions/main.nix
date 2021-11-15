# This file was generated.
# TODO: add comment at the top how to generate the file or how it was generated

{
    url = "https://github.com/holochain/holochain";
    rev = "efd47955adbf381bf9a886b0e0f9146dfd6be46c";
    sha256 = "0krgdv6a01c484a7hy9q5mnzx8vi3jwccb3qwmysnw1mwdykd9a0";
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
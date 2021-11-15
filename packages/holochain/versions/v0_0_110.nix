# This file was generated.
# TODO: add comment at the top how to generate the file or how it was generated

{
    url = "https://github.com/holochain/holochain";
    rev = "holochain-0.0.110";
    sha256 = "1fykfqslr7lhbp11wbl7cz5pmygw9wmhlkvvnfn9ig9ddr7nq6sw";
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
        rev = "v0.0.7";
        sha256 = "12n1h94b1r410lbdg4waj5jsx3rafscnw5qnhz3ky98lkdc1mnl3";

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
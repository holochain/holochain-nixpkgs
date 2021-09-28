{
    url = "https://github.com/holochain/holochain";
    rev = "14ee16ecf0bd20c215b0f238e853f6762b113c51";
    sha256 = "0rck0j1w8p8xap4s41ary2ikxz2rjnwg5ycr00yd59lbmwly53rq";
    cargoLock = {
        # lockFile = "";
        outputHashes = {
            "cargo-test-macro-0.1.0" = "1yy1y1d523xdzwg1gc77pigbcwsbawmy4b7vw8v21m7q957sk0c4";
        };
    };

    bins_filter = [
        "holochain"
        "hc"
        "kitsune-p2p-proxy"
    ];

    lair = {
        url = "https://github.com/holochain/lair";
        rev = "a3b308b0db8ebca46451ef89cfa826227fabb345";
        sha256 = "1bl3aq6jvf14nqbraq3q8jl5b1m1wmbdgxjqr7im3jgr69c3x57j";

        bins_filter = [
            "lair-keystore"
        ];

        cargoLock = {
            # lockFile = "";
            outputHashes = {
            };
        };
    };
}
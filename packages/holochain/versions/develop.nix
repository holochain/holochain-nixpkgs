{
    url = "https://github.com/holochain/holochain";
    rev = "b996d2024bb3d2a9c3cc0d7a759d8fa567c7528a";
    sha256 = "1456ivxid8rqfwq58i9fp5khq79scsdlgmvjzhzb3f6zlbvm9ywa";
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
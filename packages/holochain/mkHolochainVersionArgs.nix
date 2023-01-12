{
    holochain,
    lair,
    scaffolding,
    launcher,
}:
{
    src = holochain;
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
        src = lair;

        binsFilter = [
            "lair-keystore"
        ];


        cargoLock = {
            outputHashes = {
            };
        };
    };

    scaffolding = {
        src = scaffolding;

        binsFilter = [
            "hc-scaffold"
        ];


        cargoLock = {
            outputHashes = {
            };
        };
    };

    launcher = {
        src = launcher;

        binsFilter = [
            "hc-launch"
        ];


        cargoLock = {
            outputHashes = {
                "holochain_client-0.2.0" = "sha256-zJGc2H+dGFz5/yd9ryG6q94qBhsLdrJBjuBahcRWtGE=";
            };
        };
    };
}

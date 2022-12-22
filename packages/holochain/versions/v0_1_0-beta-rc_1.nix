# This file was generated with the following command:
# update-holochain-versions --nvfetcher-dir=nix/nvfetcher --output-file=packages/holochain/versions/v0_1_0-beta-rc_1.nix --bins-filter=holochain,hc,kitsune-p2p-proxy,kitsune-p2p-tx2-proxy --git-src=revision:holochain-0.1.0-beta-rc.1 --lair-version-req=~0.2
# For usage instructions please visit https://github.com/holochain/holochain-nixpkgs/#readme

{
    url = "https://github.com/holochain/holochain";
    rev = "holochain-0.1.0-beta-rc.1";
    sha256 = "sha256-H6kJeYP2DcMQcb5tBQpt/XtCqfr+P9XLgNMWzG1Nwaw=";
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
        rev = "lair_keystore_api-v0.2.3";
        sha256 = "sha256-cqOr7iWzsNeomYQiiFggzG5Dr4X0ysnTkjtA8iwDLAQ=";

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
        rev = "holochain_scaffolding_cli-v0.0.5-alpha.0";
        sha256 = "sha256-A0hdrgP2xeL8yr2BGYouHKPuhEvBNNgOQGR3oLK2mn4=";

        binsFilter = [
            "hc-scaffold"
        ];


        cargoLock = {
            outputHashes = {
            };
        };
    };

    launcher = {
        url = "https://github.com/holochain/launcher";
        rev = "holochain_cli_launch-0.0.3-alpha.2";
        sha256 = "sha256-LGgWfxhXg6lDcEjhNOqW5jpz4F1QumQf8ZHz727Xn2A=";

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

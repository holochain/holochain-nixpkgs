# This file was generated with the following command:
# update-holochain-versions --nvfetcher-dir=nix/nvfetcher --output-file=packages/holochain/versions/v0_0_111.nix --git-src=revision:holochain-0.0.111 --lair-version-req=~0.0
# For usage instructions please visit https://github.com/holochain/holochain-nixpkgs/#readme

{
    url = "https://github.com/holochain/holochain";
    rev = "holochain-0.0.111";
    sha256 = "sha256-EkLYJJHdOKbJDrMQk4YwAyaXN1eivFW06eLnocYNBZw=";
    cargoLock = {
        outputHashes = {
            "cargo-test-macro-0.1.0" = "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs=";
        };
    };

    binsFilter = [
        "holochain"
        "hc"
        "kitsune-p2p-proxy"
    ];

    rustVersion = "1.58.1";

    lair = {
        url = "https://github.com/holochain/lair";
        rev = "v0.0.8";
        sha256 = "sha256-AeyEQWLP2xw8WezDHqfq0oEFxYWY0E7kmuciz/qtCP8=";

        binsFilter = [
            "lair-keystore"
        ];

        rustVersion = "1.58.1";

        cargoLock = {
            outputHashes = {
            };
        };
    };
}

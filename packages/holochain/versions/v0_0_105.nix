# This file was generated with the following command:
# update-holochain-versions --nvfetcher-dir=nix/nvfetcher --output-file=packages/holochain/versions/v0_0_105.nix --bins-filter=holochain,hc,kitsune-p2p-proxy,kitsune-p2p-tx2-proxy --git-src=revision:holochain-0.0.105 --lair-version-req=~0.0
# For usage instructions please visit https://github.com/holochain/holochain-nixpkgs/#readme

{
    url = "https://github.com/holochain/holochain";
    rev = "holochain-0.0.105";
    sha256 = "sha256-v75v5XsKpOFEQ+scTRTsWzqpgrdXBb2Id3Wg25QG6j8=";
    cargoLock = {
        outputHashes = {
            "cargo-test-macro-0.1.0" = "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs=";
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
        rev = "v0.0.4";
        sha256 = "sha256-2zPhOSHH8mX6F3kfymNf9p+YxdLf4y3E0+G25wovD04=";

        binsFilter = [
            "lair-keystore"
        ];


        cargoLock = {
            outputHashes = {
            };
        };
    };
}

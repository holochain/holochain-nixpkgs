# This file was generated with the following command:
# update-holochain-versions --nvfetcher-dir=nix/nvfetcher --output-file=packages/holochain/versions/v0_0_175.nix --bins-filter=holochain,hc,kitsune-p2p-proxy,kitsune-p2p-tx2-proxy --git-src=revision:holochain-0.0.175 --lair-version-req=~0.2
# For usage instructions please visit https://github.com/holochain/holochain-nixpkgs/#readme

{
  url = "https://github.com/holochain/holochain";
  rev = "holochain-0.0.175";
  sha256 = "sha256-CSQUKjZKKwFhWtwZcB9bKZCTBVxlD5Bfikw8cTHzTDY=";
  cargoLock = { outputHashes = { }; };

  binsFilter = [ "holochain" "hc" "kitsune-p2p-proxy" "kitsune-p2p-tx2-proxy" ];

  lair = {
    url = "https://github.com/holochain/lair";
    rev = "lair_keystore_api-v0.2.2";
    sha256 = "sha256-flRc+bm4jMKa5oLOTC+v1hleAgLeRIagStEP7qm5As4=";

    binsFilter = [ "lair-keystore" ];

    cargoLock = { outputHashes = { }; };
  };

  scaffolding = {
    url = "https://github.com/holochain/scaffolding";
    rev = "holochain_scaffolding_cli-v0.0.5-alpha.1";
    sha256 = "sha256-eJPOxBU9FMEKWogD0mgGeAyY/5X0L/g5Ilh2sPe0Xs0=";

        cargoLock = {
            outputHashes = {
            };
        };
    };
}

# This file was generated with the following command:
# update-holochain-versions --nvfetcher-dir=nix/nvfetcher --output-file=packages/holochain/versions/develop.nix --bins-filter=holochain,hc,kitsune-p2p-proxy,kitsune-p2p-tx2-proxy --git-src=branch:develop --lair-version-req=~0.2
# For usage instructions please visit https://github.com/holochain/holochain-nixpkgs/#readme

{
  url = "https://github.com/holochain/holochain";
  rev = "3b292847a74c9d91c20876ddad8ef6c9997d770f";
  sha256 = "sha256-k/nKIhNHmhjhYwcRMuhKQ+ZpC64fYSY8FH1aCzhKlq8=";
  cargoLock = { outputHashes = { }; };

  binsFilter = [ "holochain" "hc" "kitsune-p2p-proxy" "kitsune-p2p-tx2-proxy" ];

  lair = {
    url = "https://github.com/holochain/lair";
    rev = "lair_keystore_api-v0.2.3";
    sha256 = "sha256-cqOr7iWzsNeomYQiiFggzG5Dr4X0ysnTkjtA8iwDLAQ=";

    binsFilter = [ "lair-keystore" ];

    cargoLock = { outputHashes = { }; };
  };

  scaffolding = {
    url = "https://github.com/holochain/scaffolding";
    rev = "holochain_scaffolding_cli-v0.0.6";
    sha256 = "sha256-IlQ1OnsJP7T4Tc3JxoRuKKDQLlg11U9DzSAezO0pZ7c=";

    binsFilter = [ "hc-scaffold" ];

    cargoLock = { outputHashes = { }; };
  };

  launcher = {
    url = "https://github.com/holochain/launcher";
    rev = "holochain_cli_launch-0.0.5";
    sha256 = "sha256-H53sxXHXifdrE0h0shQY/3DPI3eXAS74FdK7W/nj6pE=";

    binsFilter = [ "hc-launch" ];

    cargoLock = {
      outputHashes = {
        "holochain_client-0.2.0" =
          "sha256-zJGc2H+dGFz5/yd9ryG6q94qBhsLdrJBjuBahcRWtGE=";
      };
    };
  };
}

{ pkgs
, callPackage
, rustPlatform
, nvfetcher
}:

let
  holochain = callPackage ./holochain { inherit rustPlatform; };
  crate2nixGenerated = import ../nix/crate2nix/Cargo.nix { inherit pkgs; };
  update-holochain-versions = pkgs.buildEnv {
    name = "update-holochain-versions";
    paths = [
      crate2nixGenerated
        .workspaceMembers.update-holochain-versions
        .build
      pkgs.nvfetcher
    ];
  };
in
{
  inherit
    holochain
    update-holochain-versions
    ;

  inherit (pkgs)
    nvfetcher
    ;

  scripts = callPackage ./scripts.nix {
    inherit
      holochain
      update-holochain-versions
      ;
  };
}

{ pkgs, callPackage, rustPlatform }:

let
  holochain = callPackage ./holochain { inherit rustPlatform; };
  crate2nixGenerated = import ../nix/crate2nix/Cargo.nix { inherit pkgs; };
in
  {
    inherit holochain;

    inherit (pkgs)
      nvfetcher
      ;

    update-holochain-versions = pkgs.buildEnv {
      name = "update-holochain-versions";
      paths = [
        crate2nixGenerated
          .workspaceMembers.update-holochain-versions
          .build
        pkgs.nvfetcher
      ];
    };
  }

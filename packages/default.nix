{ pkgs, callPackage, rustPlatform }:

let
  holochain = callPackage ./holochain { inherit rustPlatform; };
  crate2nixGenerated = import ../nix/crate2nix/Cargo.nix { inherit pkgs; };
in
  holochain //
  {
    update-holochain-versions = crate2nixGenerated.workspaceMembers.update-holochain-versions.build;
  }

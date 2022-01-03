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
      (crate2nixGenerated.workspaceMembers.update-holochain-versions.build.override {
        # TODO: tests run nix which currently fails within a nix build.
        runTests = false;
        testPreRun = ''
          mv test test.bkp
          mkdir test
          ${pkgs.rsync}/bin/rsync -rLv test.bkp/ test/
          find test/
          chmod -R +w test

          # mkdir nix-store
          export NIX_PATH=nixpkgs=${pkgs.path}
        '';
        testInputs = [ pkgs.nixUnstable ];
      })
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

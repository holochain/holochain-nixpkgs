{ pkgs
, lib
, callPackage
, symlinkJoin
, nvfetcher
, nixUnstable
, makeWrapper
, mkRust
, makeRustPlatform
}:

let
  holochain = callPackage ./holochain { inherit mkRust makeRustPlatform; };
  crate2nixGenerated = import ../nix/crate2nix/Cargo.nix { inherit pkgs; };
  crate2nix = crate2nixGenerated.workspaceMembers.update-holochain-versions.build.override {
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
  };
  update-holochain-versions = symlinkJoin {
    inherit (crate2nix) name;
    paths = [ crate2nix ];
    buildInputs = [ makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/update-holochain-versions \
            --suffix PATH ":" ${lib.makeBinPath [ nixUnstable nvfetcher ]}
    '';
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

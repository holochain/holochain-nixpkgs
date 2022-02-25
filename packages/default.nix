{ pkgs
, lib
, stdenv
, callPackage
, symlinkJoin
, nvfetcher
, nixUnstable
, makeWrapper
, mkRust
, makeRustPlatform
, darwin
, xcbuild
}:

let
  rustInputAttrs = attrs: {
    OPENSSL_NO_VENDOR = "1";
    OPENSSL_LIB_DIR = "${opensslStatic.out}/lib";
    OPENSSL_INCLUDE_DIR = "${opensslStatic.dev}/include";

    nativeBuildInputs = (attrs.nativeBuildInputs or [ ])
      ++ (with pkgs; [
      perl
      pkg-config
    ])
      ++ (lib.optionals stdenv.isDarwin [
      xcbuild
    ])
    ;

    buildInputs = (attrs.buildInputs or [ ])
      ++ (with pkgs; [
      openssl
      zlib
      opensslStatic
      libgit2
      libssh2
    ])
      ++ (lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
      AppKit
      CoreFoundation
      CoreServices
      Security
      libiconv
    ]))
    ;
  };
  opensslStatic = pkgs.openssl.override (_: {
    static = true;
  });
  holochain = callPackage ./holochain { inherit mkRust makeRustPlatform; };
  crate2nixGenerated =
    let
    in
    import ../nix/crate2nix/Cargo.nix {
      inherit pkgs;
      defaultCrateOverrides = pkgs.defaultCrateOverrides // {
        openssl-sys = rustInputAttrs;
        libgit2-sys = rustInputAttrs;
        libssh2-sys = rustInputAttrs;
      };
    };
  update-holochain-versions-raw = crate2nixGenerated.workspaceMembers.update-holochain-versions.build.override {
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
    inherit (update-holochain-versions-raw) name;
    paths = [ update-holochain-versions-raw ];
    buildInputs = [ makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/update-holochain-versions \
            --suffix PATH ":" ${lib.makeBinPath [ nixUnstable nvfetcher ]}
    '';
  };
  holochain-nixpkgs-util-raw = crate2nixGenerated.workspaceMembers.holochain-nixpkgs-util.build;
  holochain-nixpkgs-util = symlinkJoin {
    name = holochain-nixpkgs-util-raw.name;
    paths = [ holochain-nixpkgs-util-raw ];
    buildInputs = [ makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/holochain-nixpkgs-util \
            --suffix PATH ":" ${lib.makeBinPath [ scripts.hnixpkgs-update-single ]}
    '';
  };

  scripts = callPackage ./scripts.nix {
    inherit
      holochain
      update-holochain-versions
      ;
  };
in
{
  inherit
    scripts
    holochain
    update-holochain-versions
    holochain-nixpkgs-util
    rustInputAttrs
    ;


  inherit (pkgs)
    nvfetcher
    ;

}

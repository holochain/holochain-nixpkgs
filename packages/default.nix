{ pkgs, lib, stdenv, callPackage, symlinkJoin, nixUnstable, makeWrapper, rsync

, mkRust, makeRustPlatform, defaultCrateOverrides

, perl, pkg-config, openssl, zlib, libgit2, libssh2, libsodium, darwin, xcbuild
, libiconv, curl }:

let
  rustInputAttrs = attrs: {
    RUST_SODIUM_LIB_DIR = "${libsodium}/lib";
    RUST_SODIUM_SHARED = "1";

    OPENSSL_NO_VENDOR = "1";
    OPENSSL_LIB_DIR = "${opensslStatic.out}/lib";
    OPENSSL_INCLUDE_DIR = "${opensslStatic.dev}/include";

    nativeBuildInputs = (attrs.nativeBuildInputs or [ ]) ++ [ perl pkg-config ]
      ++ (lib.optionals stdenv.isDarwin [ xcbuild ]);

    buildInputs = (attrs.buildInputs or [ ])
      ++ [ openssl zlib opensslStatic libgit2 libssh2 ]
      ++ (lib.optionals stdenv.isDarwin ((with darwin.apple_sdk.frameworks; [
        AppKit
        CoreFoundation
        CoreServices
        Security
        libiconv
      ]) ++ [ curl.dev ]));
  };
  opensslStatic = openssl.override (_: { static = true; });
  holochain = callPackage ./holochain {
    inherit mkRust makeRustPlatform;
    defaultRustVersion = pkgs.rust.packages.holochain.rust.rustc.version;
  };
  crate2nixGenerated = import ../nix/crate2nix/Cargo.nix {
    inherit pkgs;
    defaultCrateOverrides = lib.attrsets.recursiveUpdate defaultCrateOverrides {
      openssl-sys = rustInputAttrs;
      libgit2-sys = rustInputAttrs;
      libssh2-sys = rustInputAttrs;
    };
  };

  scripts =
    callPackage ./scripts.nix { inherit holochain; };
in {
  inherit scripts holochain
    rustInputAttrs;

}

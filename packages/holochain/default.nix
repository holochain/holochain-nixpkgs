{ stdenv
, rustPlatform
, fetchFromGitHub
, perl
, xcbuild
, darwin
, libsodium
, openssl
, pkgconfig
, lib
, callPackage
, rust
, libiconv
, sqlcipher
}:

let

  mkHolochainBinary = {
      rev
      , owner ? "holochain"
      , repo ? "holochain"
      , sha256
      , cargoSha256
      , crate
      , cargoBuildFlags ? [
        "--no-default-features"
        "--manifest-path=crates/${crate}/Cargo.toml"
      ]

      , ... } @ overrides: rustPlatform.buildRustPackage (lib.attrsets.recursiveUpdate {
    passthru = {
      inherit crate;
    };

    name = "holochain";
    cargoDepsName = "holochain";

    src = lib.makeOverridable fetchFromGitHub {
      inherit owner repo;
      inherit rev sha256;
    };

    inherit cargoSha256;
    inherit cargoBuildFlags;

    nativeBuildInputs = [ perl pkgconfig ] ++ lib.optionals stdenv.isDarwin [
      xcbuild
    ];

    buildInputs = [ openssl sqlcipher ] ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
      AppKit
      CoreFoundation
      CoreServices
      Security
      libiconv
    ]);

    RUST_SODIUM_LIB_DIR = "${libsodium}/lib";
    RUST_SODIUM_SHARED = "1";

    doCheck = false;
    meta.platforms = [
        "aarch64-linux"
        "x86_64-linux"
        "x86_64-darwin"
    ];
  } # remove attributes that cause failure when they're passed to `buildRustPackage`
    (builtins.removeAttrs overrides [
    "rev"
    "sha256"
    "cargoSha256"
    "crate"
    "bins"
  ]));

  mkHolochainAllBinaries = {
    rev
    , sha256
    , cargoSha256
    , bins
    , ...
  } @ overrides:
    lib.attrsets.mapAttrs (_: crate:
      mkHolochainBinary ({
        inherit rev sha256 cargoSha256 crate;
      } // overrides)
    ) bins
  ;

  mkHolochainAllBinariesWithDeps = { rev, sha256, cargoSha256, bins, lairKeystoreHashes } @ args:
    mkHolochainAllBinaries {
      inherit rev sha256 cargoSha256 bins;
    }
    // {
      lair-keystore = mkHolochainBinary {
        crate = "lair_keystore";
        repo = "lair";
        rev = let
          holochainSrc = (mkHolochainBinary {
            crate = "lair_keystore_api";
            inherit rev sha256 cargoSha256;
          }).src;
          holochainKeystoreTOML = lib.trivial.importTOML
            "${holochainSrc}/crates/holochain_keystore/Cargo.toml";
          lairKeystoreApiVersionRaw = holochainKeystoreTOML.dependencies.lair_keystore_api;
          lairKeystoreApiVersion = builtins.replaceStrings
            [ "<" ">" "=" ]
            [ ""  "" "" ]
            lairKeystoreApiVersionRaw
            ;
        in "v${lairKeystoreApiVersion}";
        inherit (lairKeystoreHashes) sha256 cargoSha256;
      };
    }
    ;

  versions = import ./versions.nix;
in

{
  inherit
    mkHolochainBinary
    mkHolochainAllBinaries
    mkHolochainAllBinariesWithDeps
    ;

  holochainVersions = versions;

  holochainAllBinariesWithDeps = builtins.mapAttrs (_name: value:
    mkHolochainAllBinariesWithDeps value
  ) {
    inherit (versions)
      develop
      main
      ;
  };
}

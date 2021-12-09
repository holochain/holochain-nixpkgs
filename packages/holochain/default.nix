{ stdenv
, fetchgit
, perl
, xcbuild
, darwin
, libsodium
, openssl
, pkg-config
, lib
, callPackage
, libiconv
, sqlcipher
, opensslStatic ? openssl.override (_: {
    static = true;
  })
, runCommand
, cargo
, jq
, mkRust
, makeRustPlatform
}:

# TODO: investigate the use-case around 'binsFilter' with end-users before further optimizations

let
  binaryPackages =
    { url
    , rev
    , sha256
    , binsFilter ? null
    }:

    let
      src = fetchgit {
        inherit url rev sha256;

        deepClone = false;
        leaveDotGit = false;
      };

      # evaluate all packages and their binaries
      cargoMetadataOutput = runCommand "packages_binaries" { } ''
        ${cargo}/bin/cargo metadata --format-version 1 --no-deps --manifest-path ${src}/Cargo.toml | \
          ${jq}/bin/jq '.packages | map(
          {name: .name, target: .targets[]}
          | select(.target.kind | contains(["bin"]))
          | {name: .name, binaries: [.target.name]}
          )
          | reduce .[] as $package ({}; . + { ($package.name): (.[($package.name)] + $package.binaries) })
          ' > $out
      '';

      # contains a set of (package_name: [binary_names...])
      # example: { holochain_cli = [ "hc" ]; }
      packageBinaries = lib.trivial.importJSON cargoMetadataOutput;

      # we want the output names to be valid shell variable names so we can refer to them in the postInstall script
      # we also want a mapping between the compatible name and the original binary name, so we can actually copy them
      # thus, this value stores map from the original binary names to the shell compatible names.
      binariesCompat = builtins.listToAttrs
        (lib.lists.flatten
          (builtins.attrValues
            (builtins.mapAttrs
              (binaries:
                builtins.map
                  (binary:
                    (lib.attrsets.nameValuePair
                      binary
                      (builtins.replaceStrings [ "-" ] [ "_" ] binary)
                    )
                  )
              )
              packageBinaries
            )
          )
        )
      ;
    in
    {
      inherit
        packageBinaries
        binariesCompat
        ;

      binariesCompatFiltered =
        if binsFilter == null
        then binariesCompat
        else
          (lib.attrsets.filterAttrs
            (binary: _:
              (builtins.elem binary binsFilter)
            )
            binariesCompat
          )
      ;
    };

  # this derivation builds all binaries in a rust repository, creating one output per binary
  mkRustMultiDrv =
    { rev
    , url
    , sha256
    , cargoLock
    , cargoBuildFlags ? [ ]
    , binsFilter ? null
    , binaryPackagesResult ? binaryPackages { inherit url rev sha256 binsFilter; }
    , rustVersion
    }:
    let
      filteredBinariesCompat = binaryPackagesResult.binariesCompatFiltered;
      pname = builtins.toString (builtins.replaceStrings [ "https" "http" "git+" "://" "/" ] [ "" "" "" "" "_" ] url);
      src = fetchgit {
        inherit url rev sha256;

        deepClone = false;
        leaveDotGit = false;
      };

      rust = mkRust { track = "stable"; version = rustVersion; };
      rustPlatform = makeRustPlatform { rustc = rust; cargo = rust; };

    in
    rustPlatform.buildRustPackage {
      passthru = {
        inherit binaryPackagesResult;
      };

      inherit
        src
        pname
        ;

      cargoDepsName = pname + "-" + rev;
      name = pname + "-" + rev;

      cargoLock = cargoLock // {
        lockFile = "${src}/Cargo.lock";
      };

      cargoBuildFlags = builtins.concatStringsSep " " [
        (builtins.concatStringsSep " " cargoBuildFlags)
        # only build the binaries that were requested and found
        (builtins.concatStringsSep " " (builtins.map (bin: "--bin ${bin}") (builtins.attrNames filteredBinariesCompat)))
      ];

      outputs = [
        "out"
        "bin"
      ]
      # this evaluates to all the shell compatible binary names
      ++ builtins.attrValues filteredBinariesCompat
      ;

      postInstall = ''
        for d in $outputs; do
          mkdir -p ''${!d}/bin
        done
      '' + builtins.concatStringsSep "\n" (lib.attrsets.mapAttrsToList
        (orig: compat:
          ''mv ''${tmpDir}/${orig} ''\${${compat}}/bin/''
        )
        filteredBinariesCompat
      )
      ;

      nativeBuildInputs = [ perl pkg-config ] ++ lib.optionals stdenv.isDarwin [
        xcbuild
      ];

      buildInputs = [ openssl opensslStatic sqlcipher ] ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
        AppKit
        CoreFoundation
        CoreServices
        Security
        libiconv
      ]);

      RUST_SODIUM_LIB_DIR = "${libsodium}/lib";
      RUST_SODIUM_SHARED = "1";

      OPENSSL_NO_VENDOR = "1";
      OPENSSL_LIB_DIR = "${opensslStatic.out}/lib";
      OPENSSL_INCLUDE_DIR = "${opensslStatic.dev}/include";

      doCheck = false;

      meta.platforms = [
        "aarch64-linux"
        "x86_64-linux"
        "x86_64-darwin"
      ];
    };

  mkHolochainAllBinaries =
    { url
    , rev
    , sha256
    , cargoLock
    , binsFilter
    , rustVersion
    }:
    let
      binaryPackagesResult = binaryPackages { inherit url rev sha256 binsFilter; };
    in

    lib.attrsets.mapAttrs
      (_: compat:
      builtins.getAttr compat (mkRustMultiDrv {
        inherit url rev sha256 cargoLock binaryPackagesResult rustVersion;
      })
      )
      binaryPackagesResult.binariesCompatFiltered
  ;

  mkHolochainAllBinariesWithDeps = { url, rev, sha256, cargoLock, binsFilter ? null, lair, rustVersion }:
    (mkHolochainAllBinaries {
      inherit url rev sha256 cargoLock binsFilter rustVersion;
    })
    // (lib.optionalAttrs (lair != null) {
      lair-keystore = (mkRustMultiDrv {
        inherit (lair) url rev sha256 cargoLock binsFilter rustVersion;
      }).lair_keystore;
    })
  ;

  holochainVersions = lib.attrsets.mapAttrs'
    (name': value':
      {
        name = lib.strings.replaceStrings [ ".nix" ] [ "" ] name';
        value = import ((builtins.toString ./.) + "/versions/${name'}");
      }
    )

    (lib.attrsets.filterAttrs
      (name: value:
        (lib.strings.hasSuffix ".nix" name) && (value == "regular")
      )
      (builtins.readDir ./versions)
    );
in

{
  inherit
    mkHolochainAllBinaries
    mkHolochainAllBinariesWithDeps
    holochainVersions
    ;

  holochainVersionUpdateConfig = lib.trivial.importTOML ./versions/update_config.toml;

  holochainAllBinariesWithDeps = builtins.mapAttrs
    (_: versionValue:
      mkHolochainAllBinariesWithDeps versionValue
    )
    holochainVersions;

}

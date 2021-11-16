# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ sources ? import ./nix/nvfetcher/sources.nix {}
, system ? builtins.currentSystem
, crossSystem ? null
, overlays ? builtins.attrValues (import ./overlays)

, pkgs ? import sources.nixpkgs.src {
    inherit system crossSystem overlays;
  }
, pkgsUnstable ? import sources.nixpkgs-unstable.src {
    inherit system crossSystem overlays;
  }

, pkgsMasterPath ? sources.nixpkgs-steveej.src
# , pkgsMasterPath ? sources.nixpkgs-master.src
, pkgsMaster ? import pkgsMasterPath {
    inherit system crossSystem overlays;
  }

, rustPlatformSelector ? "stable"
, rustPlatform ? pkgsMaster.rust.packages."${rustPlatformSelector}".rustPlatform
}:

let
  packages = pkgs.callPackage ./packages { inherit rustPlatform; };
in

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # expose the sources
  inherit sources;

  # expose the imported nixpkgs
  inherit pkgs;
  inherit pkgsUnstable;

  # expose packages
  inherit packages;

  # expose this derivation as the only one so it is used by `nix-shell`
  shellDerivation = pkgs.mkShell {
    name = "env";

    NIX_PATH = "nixpkgs=${sources.nixpkgs.src}";

    packages = (with pkgs; [
        # for nix-shell --pure
        git cacert nix

        nix-build-uncached
        rustPlatform.rust.rustc

        nvfetcher
        crate2nix

        (writeScriptBin "nvfetcher-build" ''
          pushd ${toString ./.}/nix/nvfetcher
          ${nvfetcher}/bin/nvfetcher build $@
        '')

        (writeScriptBin "nvfetcher-clean" ''
          pushd ${toString ./.}/nix/nvfetcher
          ${nvfetcher}/bin/nvfetcher clean $@
        '')

        (writeScriptBin "hnixpkgs-update-all" (
        let
          toplevel = (builtins.toString ./.);

          updateAll = builtins.concatStringsSep "\n" (lib.attrsets.mapAttrsToList
              (key: value:
              let
                extraArgs = builtins.concatStringsSep " " (lib.attrsets.mapAttrsToList
                  (key': value': ''--${key'}="${value'}"'')
                  value
                );
              in
                  ''
                  ${packages.update-holochain-versions}/bin/update-holochain-versions \
                      --nvfetcher-dir=${toplevel}/nix/nvfetcher \
                      --output-file=${toplevel}/packages/holochain/versions/${key}.nix \
                      ${extraArgs} \
                      ;
                  ''
              )
              packages.holochain.holochainVersionUpdateConfig
            );

          diffTargets = "${toplevel}/packages/holochain/versions ${toplevel}/nix/nvfetcher/_sources/generated.nix";
          commitPaths = "${toplevel}/packages/holochain/versions ${toplevel}/nix/nvfetcher";
        in ''
          set -e

          pushd ${toplevel}

          trap "git checkout ${toplevel}/nix/nvfetcher" ERR INT
          nvfetcher-clean

          ${updateAll}

          trap "" ERR INT

          ${git}/bin/git add ${commitPaths}

          if ${git}/bin/git diff --staged --exit-code -- ${diffTargets}; then
              echo No updates found.
          else
              echo Updates found, commiting..
              ${git}/bin/git commit ${commitPaths} -m "update all sources and holochain versions"
          fi
        ''))

        (let
          toplevel = (builtins.toString ./.);
          outputPath = "nix/crate2nix/Cargo.nix";
          diffTargets = "${outputPath} Cargo.lock";
          buildTargets = "-A packages.update-holochain-versions";
        in
          writeScriptBin "hnixpkgs-regen-crate-expressions" ''
          set -e
          pushd ${toplevel}

          ${cargo}/bin/cargo generate-lockfile
          ${crate2nix}/bin/crate2nix generate --default-features --output=${outputPath}

          if git diff --exit-code -- ${diffTargets}; then
              echo No updates found.
          else
              nix-build default.nix --no-out-link ${buildTargets}
              echo Updates found, commiting..
              git commit ${diffTargets} -m "update generated crate expressions"
          fi
        '')
    ]);
  };
}

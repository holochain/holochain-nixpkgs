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
  packages = pkgs.callPackage ./packages { inherit rustPlatform; };

  # expose this derivation as the only one so it is used by `nix-shell`
  shellDerivation = pkgs.mkShell {
    name = "env";
    packages = (with pkgs; [
        nix-build-uncached
        rustPlatform.rust.rustc

        nvfetcher
        crate2nix

        (pkgs.writeScriptBin "nvfetcher-build" ''
          pushd ${toString ./.}/nix/nvfetcher
          ${nvfetcher}/bin/nvfetcher build $@
        '')

        (pkgs.writeScriptBin "nvfetcher-clean" ''
          pushd ${toString ./.}/nix/nvfetcher
          ${nvfetcher}/bin/nvfetcher clean $@
        '')

        (pkgs.writeScriptBin "hnixpkgs-update-all" (
        let
          # FIXME: DRY the script
        in ''
          set -e
          for branch in develop main; do
              cargo run -p update-holochain-versions -- --git-rev=branch:''${branch} --output-file=packages/holochain/versions/''${branch}.nix --nvfetcher-dir=nix/nvfetcher/
          done

          if git diff --exit-code -- packages/holochain/versions nix/nvfetcher/_sources/generated.nix; then
              echo No updates found.
          else
              echo Updates found, commiting..
              git add nix/nvfetcher
              git commit packages/holochain/versions nix/nvfetcher -m "update all sources and holochain versions"
          fi
        ''))

        (let
          toplevel = (builtins.toString ./.);
          outputPath = "nix/crate2nix/Cargo.nix";
          diffTargets = "${outputPath} Cargo.lock";
          buildTargets = "-A packages.update-holochain-versions";
        in
          pkgs.writeScriptBin "hnixpkgs-regen-crate-expressions" ''
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

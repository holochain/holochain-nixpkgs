# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ sources ? import ./nix/nvfetcher/sources.nix { }
, system ? builtins.currentSystem
, crossSystem ? null
, overlays ? builtins.attrValues (import ./overlays)

, pkgs ? import sources.nixpkgs.src {
    inherit system crossSystem overlays;
  }

, rustPlatformSelector ? "stable"
, rustPlatform ? pkgs.rust.packages."${rustPlatformSelector}".rustPlatform

, flavors ? [ "dev" ]
}:

let
  packages = pkgs.callPackage ./packages { inherit (pkgs) makeRustPlatform; mkRust = pkgs.rust.mkRust; };
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

  # expose packages
  inherit packages;

  # expose this derivation as the only one so it is used by `nix-shell`
  shellDerivation = pkgs.mkShell {
    name = "env";

    NIX_PATH = "nixpkgs=${sources.nixpkgs.src}";
    NIX_CONFIG = "extra-experimental-features = nix-command";

    inputsFrom = pkgs.lib.optionals (builtins.elem "dev" flavors) [
      (packages.rustInputAttrs { attrs = { }; })
    ];

    packages = [
      # for nix-shell --pure
      pkgs.git
      pkgs.git-lfs
      pkgs.gh
      pkgs.cacert
      pkgs.nixUnstable
      # pkgs.nix-build-uncached

      packages.scripts.nvfetcher-build
      packages.scripts.nvfetcher-clean
    ] ++ pkgs.lib.optionals (builtins.elem "dev" flavors) [
      rustPlatform.rust.rustc
      rustPlatform.rust.cargo
      pkgs.nixpkgs-fmt

      pkgs.crate2nix
      packages.scripts.nixpkgs-regen-crate-expressions
      packages.scripts.hnixpkgs-update-nvfetcher-src
      packages.scripts.hnixpkgs-iter
    ] ++ pkgs.lib.optionals (builtins.elem "release" flavors) [
      packages.update-holochain-versions
      packages.holochain-nixpkgs-util

      packages.scripts.hnixpkgs-update-single
      packages.scripts.hnixpkgs-update-all
    ]
    ;
  };
}

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

  # expose packages
  inherit packages;

  # expose this derivation as the only one so it is used by `nix-shell`
  shellDerivation = pkgs.mkShell {
    name = "env";

    NIX_PATH = "nixpkgs=${sources.nixpkgs.src}";

    packages = [
      # for nix-shell --pure
      pkgs.git
      pkgs.cacert
      pkgs.nix

      packages.scripts.nvfetcher-build
      packages.scripts.nvfetcher-clean
      # pkgs.nix-build-uncached
    ] ++ pkgs.lib.optionals (builtins.elem "dev" flavors) [
      rustPlatform.rust.rustc
      rustPlatform.rust.cargo
      pkgs.nvfetcher
      pkgs.nixpkgs-fmt
      packages.scripts.nixpkgs-regen-crate-expressions
      pkgs.crate2nix
    ] ++ pkgs.lib.optionals (builtins.elem "release" flavors) [
      packages.scripts.hnixpkgs-update-all
    ]
    ;
  };
}

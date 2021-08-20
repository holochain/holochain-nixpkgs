# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ sources ? import ./nix/sources.nix
, system ? builtins.currentSystem
, crossSystem ? null
, overlays ? builtins.attrValues (import ./overlays)
, pkgs ? import sources.nixpkgs {
    inherit system crossSystem overlays;
  }

, rustPlatform ? pkgs.rust.packages.stable.rustPlatform
}:

let
  packages = pkgs.callPackage ./packages { inherit rustPlatform; };
in

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays


  # expose the imported nixpkgs
  inherit pkgs;

  # expose packages
  inherit packages;
}

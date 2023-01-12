{ flake ? (import ./nix/compat.nix)
, flakeSources ? builtins.mapAttrs (_: inp: {src = "${inp}";}) flake.inputs
, sources ? flakeSources
, system ? builtins.currentSystem, crossSystem ? null
, overlays ? builtins.attrValues (import ./overlays)

, pkgs ? import flake.inputs.nixpkgs { inherit system crossSystem overlays; }

, rustPlatformSelector ? "stable"
, rustPlatform ? pkgs.rust.packages."${rustPlatformSelector}".rustPlatform

, flavors ? [ "dev" ] }:

import ./nix/default_old.nix {
  inherit
    sources
    crossSystem
    system
    pkgs
    rustPlatformSelector
    rustPlatform
    flavors
    ;
}

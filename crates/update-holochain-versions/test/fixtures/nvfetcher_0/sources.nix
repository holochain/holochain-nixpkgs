
{ generated ? ./_sources/generated.nix }:
let
  _nixpkgs = ((import <nixpkgs> {}).callPackage ./_sources/generated.nix { }).nixpkgs.src;
  nixpkgs = import _nixpkgs {};
in nixpkgs.callPackage generated {}

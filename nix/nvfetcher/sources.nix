{ generated ? ./_sources/generated.nix }:
let
  _nixpkgs = (import ./_sources/generated.nix {
    fetchgit = null;
    fetchurl = null;
    fetchFromGitHub = null;
  }).nixpkgs.src;
  nixpkgs = import _nixpkgs { };
in
nixpkgs.callPackage generated { }

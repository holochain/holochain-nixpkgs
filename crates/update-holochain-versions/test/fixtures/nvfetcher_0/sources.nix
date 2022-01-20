
{ generated ? ./_sources/generated.nix }:
let
  # _nixpkgs = ((import <nixpkgs> { }).callPackage ./_sources/generated.nix { }).nixpkgs.src;
  _nixpkgs = (import ./_sources/generated.nix { fetchurl = null; fetchFromGitHub = null; fetchgit = { url, rev, sha256, fetchSubmodules, deepClone, leaveDotGit }: builtins.fetchGit { inherit url rev; allRefs = true; submodules = fetchSubmodules; }; }).nixpkgs.src;
  nixpkgs = import _nixpkgs {};
in nixpkgs.callPackage generated {}

#!/bin/sh

set -x
export NIX_PATH=nixpkgs=$(nix eval --raw --impure --expr '(import ./nix/nvfetcher/_sources/generated.nix { fetchurl = null; fetchFromGitHub = null; fetchgit = { url, rev, sha256, fetchSubmodules, deepClone, leaveDotGit }: builtins.fetchGit { inherit url rev; allRefs = true; submodules = fetchSubmodules; }; }).nixpkgs.src.outPath')
set +x

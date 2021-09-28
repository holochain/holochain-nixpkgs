# Holochain nixpkgs

![build status](https://github.com/holochain/holochain-nixpkgs/actions/workflows/build.yml/badge.svg)

[![Cachix Cache](https://img.shields.io/badge/cachix/holochain-ci-blue.svg)](https://holochain-ci.cachix.org)

**The holochain [Nix User Repository](https://github.com/nix-community/NUR)**

This repository is used to maintain the nix expressions that package holochain and other binaries that are required and useful for using it.

## Manual Update Process

### Holochain Versions

```shell
nix-shell --pure "hnixpkgs-update-all"
```

### Generated Nix Expressions

```shell
nix-shell --pure "hnixpkgs-regen-crate-expressions"
```

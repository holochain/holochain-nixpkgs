# Holochain nixpkgs

![build status](https://github.com/holochain/holochain-nixpkgs/actions/workflows/build.yml/badge.svg)

[![Cachix Cache](https://img.shields.io/badge/cachix/holochain-ci-blue.svg)](https://holochain-ci.cachix.org)

**The holochain [Nix User Repository](https://github.com/nix-community/NUR)**

This repository is used to maintain the nix expressions that package holochain and other binaries that are required and useful for using it.

## Development

### Generated Nix Expressions

After making changes to (Rust) code in `crates/`  please regenerate the corresponding Nix expressions.
The following command takes care of that and of committing the changed files to git.

```shell
nix-shell --pure "hnixpkgs-regen-crate-expressions"
```


## Holochain Version Configurations

This repository tracks multiple versions configurations of holochain and lair.

The desired configurations are specified in _packages/holochain/versions/update_config.toml_.
The resulting version files are stored in separate files as Nix expressions matched by the glob _`packages/holochain/versions/*.nix_.

Each entry in the config file corresponds to one Nix file.
Each Nix file will expose a set of binary packages (holochain, hc, ..., lair-keystore) that can be built like this:

```shell
nix build -f . packages.holochain.holochainAllBinariesWithDeps.<filename>.<binary>
```

### Update Configuration Format

The TOML file contains one table per Nix expression.

The table name corresponds to the Nix expression filename.
It must only contain valid filesystem characters and no _._ character.

Each table key-value pair will be passed to the updater utility in the form of `--${key}=${value}`.
Please see the updater utility section for a list of valid arguments.

### Adding/Changing a version configuration entry

After adding or changing en entry in the aforementioned file, the following command will update existing and add new files as appropriate:

```shell
nix-shell --pure "hnixpkgs-update-all"
```

If you want the new configuration to be cached by CI, please also add an entry to the matrix defined in _.github/workflows/build.yml_.
More on this in the section below.

#### Example

```toml
[develop_lair_0_1]
git-rev = "branch:develop"
lair-version-req = "~0.1"
```

After updating the files with the aforementioned command you could (build and run) holochain and lair-keystore like so.

```shell
$ nix run -f . packages.holochain.holochainAllBinariesWithDeps.develop_lair_0_1.holochain -c holochain --version && nix run -f . packages.holochain.holochainAllBinariesWithDeps.develop_lair_0_1.lair-keystore -c lair-keystore --version
holochain 0.0.114
lair_keystore 0.1.0
```

### Holochain Version Update Utility

```shell
nix run -f . packages.update-holochain-versions -c update-holochain-versions --help
```

## Nix Caching and Continuous Integration

This repository uses GitHub Actions to build selected Nix expressions and uploadsa them to Cachix.
The following snippet demonstrates the holochain version configurations names that will be built and cached by CI. Each item in the list at _nixAttribute_ corresponds to one holochain version configuration.

```yaml
(...)
jobs:
  holochain-binaries:
    strategy:
      fail-fast: false
      matrix:
        platform:
          - ubuntu-latest
          - macos-latest
        nixAttribute:
          - main
          - develop
          - develop_lair_0_1
          - v0_0_110
(...)
```

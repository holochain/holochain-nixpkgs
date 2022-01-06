# Holochain nixpkgs

![build status](https://github.com/holochain/holochain-nixpkgs/actions/workflows/build.yml/badge.svg)

[![Cachix Cache](https://img.shields.io/badge/cachix/holochain-ci-blue.svg)](https://holochain-ci.cachix.org)

**The holochain [Nix User Repository](https://github.com/nix-community/NUR)**

This repository contains nix expressions that package holochain and other related binaries (e.g. lair-keystore).

## Usage

Using holonix, you
1. Create a `default.nix` file describing what holochain version you need
2. Run `nix-shell` from the same folder as the `default.nix` file, which puts you into a shell environment where you can run `holochain` at the requested version

You can create a `default.nix` file in each repository you're working on that uses holochain. This could be useful if you're working on various projects that use different versions of holochain, or if you're collaborating on a project and want to update the holochain version it uses.

### Installing Nix

See <https://developer.holochain.org/install/> for instructions on Installing the Nix Package Manager

### Using a pre-built Holochain Version

Some versions of holochain are pre-built. Here is an example `default.nix` that uses the pre-built version `main`:

```nix
let
  holonixPath = builtins.fetchTarball "https://github.com/holochain/holonix/archive/f3ecb117bdd876b8dcb33ad04984c5da5b2d358c.tar.gz";
  holonix = import (holonixPath) {
    holochainVersionId = "main";
  };
  nixpkgs = holonix.pkgs;
in nixpkgs.mkShell {
  inputsFrom = [ holonix.main ];
  packages = [
    # additional packages go here
  ];
}
```

There are many available pre-built versions. To see the complete list, run the following command:
```shell
$ nix eval -I holochain-nixpkgs=https://github.com/holochain/holochain-nixpkgs/archive/develop.tar.gz '(builtins.attrNames (import <holochain-nixpkgs> {}).packages.holochain.holochainVersions)'
```

At the time of writing, this returns
```nix
[ "develop" "develop_lair_0_0" "develop_lair_0_1" "main" "v0_0_110" ]
```

#### Reducing compile times with Cachix

If you just use that `default.nix` above, you may have to compile holochain locally, which takes a long time. To skip this entirely, you can configure Nix to use a pre-compiled version instead. See <https://app.cachix.org/cache/holochain-ci#pull> for more information.

### Using a custom Holochain Version

If the pre-built versions do not satisfy your use-case, you can specify a custom revision of holochain to use. Here is an example `default.nix`:

```nix
let
  holonixPath = builtins.fetchTarball "https://github.com/holochain/holonix/archive/f3ecb117bdd876b8dcb33ad04984c5da5b2d358c.tar.gz";
  holonix = import (holonixPath) {
    holochainVersionId = "custom";
    holochainVersion = import ./holochain_version.nix;
  };
  nixpkgs = holonix.pkgs;
in nixpkgs.mkShell {
  inputsFrom = [ holonix.main ];
  packages = [
    # additional packages go here
  ];
}
```

This requires that you create a `holochain_version.nix` file as well. You can automatically generate one with the following command:

```shell
nix run -f https://github.com/holochain/holochain-nixpkgs/archive/develop.tar.gz packages.update-holochain-versions -c update-holochain-versions \
--git-src=revision:holochain-0.0.115  --lair-version-req='~0.1' --output-file=holochain_version.nix
```

`holochain-0.1.115` can be replaced with any commit hash or tag from the [Holochain repo](https://github.com/holochain/holochain), and `~0.1` can be replaced with any [SemVer specification](https://doc.rust-lang.org/cargo/reference/specifying-dependencies.html) for [lair_keystore](https://crates.io/crates/lair_keystore)

## Development

Read this section if you're interested in contributing a change to this repository.

### Generated Nix Expressions

After making changes to (Rust) code in `crates/`  please regenerate the corresponding Nix expressions.
The following command takes care of that and of committing the changed files to git.

```shell
nix-shell --pure "hnixpkgs-regen-crate-expressions"
```


## Holochain Version Configurations

This repository tracks multiple versions configurations of holochain and lair.

The desired configurations are specified in _packages/holochain/versions/update_config.toml_.
The resulting version files are stored in separate files as Nix expressions matched by the glob _packages/holochain/versions/*.nix_.

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
git-src = "branch:develop"
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

This repository uses GitHub Actions to build selected Nix expressions and uploads them to Cachix.
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

[holonix]: https://github.com/holochain/holonix

# Holochain nixpkgs

![build status](https://github.com/holochain/holochain-nixpkgs/actions/workflows/build.yml/badge.svg)

[![Cachix Cache](https://img.shields.io/badge/cachix/holochain-ci-blue.svg)](https://holochain-ci.cachix.org)

**The holochain [Nix User Repository](https://github.com/nix-community/NUR)**

This repository is used to maintain the nix expressions that package holochain and other binaries that are required and useful for using it.

## Usage

Read this section if you're interested in using the tools and packages provided by this repository.
All given commands assume that you have a working installation of Nix.

### Using a packaged Holochain Version (with Holonix)

For a list of available version configurations please browse the `*.nix` files [packages/holochain/versions/]().

If you would like to receive these programmatically, the following example command can get you started.
Note that it was executed during the time of development against the _staging_ branch.
You probably want to run this against the _develop_ branch, or even against a pinned revision.

```shell
$ nix eval -I holochain-nixpkgs=https://github.com/holochain/holochain-nixpkgs/archive/staging.tar.gz '(builtins.attrNames (import <holochain-nixpkgs> {}).packages.holochain.holochainVersions)'
[ "develop" "develop_lair_0_0" "develop_lair_0_1" "main" "v0_0_110" ]

```

All available versions are also uploaded to Cachix by our CI.
Instructions on how to setup downloading the Holochain binaries from this cache instead of rebuilding them on your machine can be found here: https://app.cachix.org/cache/holochain-ci#pull.


#### Holonix

In your `default.nix`, pass any of the above strings as the value to the `holochainVersionId` argument. Here's an impure example that uses holonix' staging branch and instructs it to use the _v0\_0\_110_ holochain version.

```nix
let
  holonixPath = builtins.fetchTarball "https://github.com/holochain/holonix/archive/staging.tar.gz";
  holonix = import (holonixPath) {
    holochainVersionId = "v0_0_110";
  };
  nixpkgs = holonix.pkgs;
in nixpkgs.mkShell {
  inputsFrom = [ holonix.main ];
  packages = [
    # additional packages go here
  ];
}
```

### Using a custom Holochain Version (with Holonix)

The Holochain version configuration snippets are used within this repository as well as by [Holonix][holonix] and its users.
While we maintain common versions in this repository, you may be intersted in using a different Holochain revision or branch, or a specific Lair version.

The following command generates a version configuration for the _holochain-0.0.115_ revision, which is a [tag in the holochain repository](https://github.com/holochain/holochain/releases/tag/holochain-0.0.115), and it chooses the Lair version that matches the _~0.1_ semantic version requirement.

```shell
nix run -f https://github.com/holochain/holochain-nixpkgs/archive/staging.tar.gz packages.update-holochain-versions -c update-holochain-versions --git-src=revision:holochain-0.0.115 --output-file=/dev/stdout --lair-version-req='~0.1'
```

#### Holonix

In your `default.nix`, set the `holochainVersionId` to _custom_ and set the `holochainVersion` argument to the generated version config. Here's an impure example that uses holonix' staging branch and maintains the version config in a separate file called _holochain\_version.nix_.

```shell
nix run -f https://github.com/holochain/holochain-nixpkgs/archive/staging.tar.gz packages.update-holochain-versions -c update-holochain-versions --git-src=revision:holochain-0.0.115 --output-file=holochain_version.nix --lair-version-req='~0.1'
```

```nix
let
  holonixPath = builtins.fetchTarball "https://github.com/holochain/holonix/archive/staging.tar.gz";
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

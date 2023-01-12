{
  description = "The new, performant, and simplified version of Holochain on Rust (sometimes called Holochain RSM for Refactored State Model) ";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    crate2nix = {
      url = "github:kolloch/crate2nix";
      flake = false;
    };

    # lair
    lair = {
      url = "github:holochain/lair/lair_keystore_api-v0.2.3";
      flake = false;
    };

    # holochain_scaffolding_cli
    scaffolding = {
      url = "github:holochain/scaffolding/holochain_scaffolding_cli-v0.0.6";
      flake = false;
    };

    # launcher
    launcher = {
      url = "github:holochain/launcher/holochain_cli_launch-0.0.4-alpha.1";
      flake = false;
    };

    # holochain
    holochain_main = {
      url = "github:holochain/holochain";
      flake = false;
    };
    holochain_develop = {
      url = "github:holochain/holochain/develop";
      flake = false;
    };
    holochain_v0_0_171 = {
      url = "github:holochain/holochain/holochain-0.0.171";
      flake = false;
    };
    holochain_v0_0_172 = {
      url = "github:holochain/holochain/holochain-0.0.172";
      flake = false;
    };
    holochain_v0_0_173 = {
      url = "github:holochain/holochain/holochain-0.0.173";
      flake = false;
    };
    holochain_v0_0_174 = {
      url = "github:holochain/holochain/holochain-0.0.174";
      flake = false;
    };
    holochain_v0_0_175 = {
      url = "github:holochain/holochain/holochain-0.0.175";
      flake = false;
    };
    holochain_v0_1_0-beta-rc_0 = {
      url = "github:holochain/holochain/holochain-0.1.0-beta-rc.0";
      flake = false;
    };
    holochain_v0_1_0-beta-rc_1 = {
      url = "github:holochain/holochain/holochain-0.1.0-beta-rc.1";
      flake = false;
    };
    holochain_v0_1_0-beta-rc_2 = {
      url = "github:holochain/holochain/holochain-0.1.0-beta-rc.2";
      flake = false;
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./nix/modules/devShells.nix
        ./nix/modules/holochainPackages.nix
        ./nix/modules/nixpkgsVersion.nix
        ./nix/modules/NIX_PATH.nix
      ];
      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
      perSystem = { config, self', inputs', ... }: {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

      };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.
      };
    };
}

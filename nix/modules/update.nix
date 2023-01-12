{ self, lib, ... }: {
  perSystem = { config, self', inputs', pkgs, system,... }: let
    holochainTags' =
      lib.filterAttrs
      (name: _: lib.hasPrefix "holochain_v" name)
      self'.packages;
    holochainTags = lib.attrNames holochainTags';

    update-holochain-tags = pkgs.writeScript "update-holochain-tags" ''
      nix flake lock --update-input ${lib.concatStringsSep " --update-input " holochainTags}
    '';

    update-holochain-main = pkgs.writeScript "update-holochain-tags" ''
      nix flake lock --update-input holochain_main
    '';

    update-holochain-develop = pkgs.writeScript "update-holochain-tags" ''
      nix flake lock --update-input holochain_develop
    '';

    update-rust-overlay = pkgs.writeScript "update-holochain-tags" ''
      nix flake lock --update-input rust-overlay
    '';

    update-nixpkgs = pkgs.writeScript "update-holochain-tags" ''
      nix flake lock --update-input nixpkgs
    '';

    mkApp = script : {type = "app"; program = toString script;};

  in {
    apps = lib.mapAttrs (_: mkApp) {
      inherit
        update-holochain-tags
        update-holochain-main
        update-holochain-develop
        update-rust-overlay
        update-nixpkgs
        ;
    };
  };
}

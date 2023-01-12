{ self, lib, ... }: {
  perSystem = { config, self', inputs', pkgs, system,... }: let
    holochainPackages' =
      lib.filterAttrs
      (name: _: lib.hasPrefix "holochain_" name)
      self'.packages;
    holochainPackages = lib.attrValues holochainPackages';
    check-all-holochain-packages = pkgs.runCommand
      "build-all-holochain-versions"
      {}
      ''
        echo "${lib.concatStringsSep "" holochainPackages}"
        touch $out
      '';
  in {
    packages = {inherit check-all-holochain-packages;};
  };
}

{ self, lib, ... }: {
  perSystem = { config, self', inputs', pkgs, system,... }: let
    defaultNix = import ../../default.nix {
      inherit system;
      flake = self;
    };
    # `nix flake show` is incompatible with IFD by default
    # This works around the issue by making the name of the package
    #   discoverable without IFD.
    mkNoIfdPackage = name: pkg: {
      inherit name;
      inherit (pkg.holochain) drvPath outPath;
      type = "derivation";
    };
    packagesNoIfd =
      lib.mapAttrs
      mkNoIfdPackage
      defaultNix.packages.holochain.holochainAllBinariesWithDeps;
  in {
    packages =
      packagesNoIfd
      // {
        holochain = packagesNoIfd.holochain_main;
      };
  };
}

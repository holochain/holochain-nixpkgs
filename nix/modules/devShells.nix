{ self, lib, ... }: {
  perSystem = { config, self', inputs', pkgs, system,... }: let
    defaultNix = import ../../default.nix {
      inherit system;
      flake = self;
    };
  in {
    devShells.default = defaultNix.shellDerivation;
  };
}

{ inputs, ... }: {
  flake = {
    nixpkgsVersion = inputs.nixpkgs.lib.version;
  };
}

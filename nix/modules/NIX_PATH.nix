{ inputs, ... }: {
  flake = {
    NIX_PATH = "nixpkgs=${inputs.nixpkgs}";
  };
}

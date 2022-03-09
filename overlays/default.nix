{
  # Add your overlays here
  #
  sources = _: _: {
    localSources = (import ../default.nix {}).sources;
  };

  overrides = self: super: {
    toplevel = builtins.toString ./..;
    nvfetcher = (import self.localSources.nvfetcher.src).defaultPackage."${self.system}";
    crate2nix = (import self.localSources.crate2nix.src {});
  };

  rust-overlay = import ./rust-overlay.nix;
  rust = import ./rust.nix;

  packages = self: super: {
    holochainPackages = self.callPackage ../packages {
      inherit (self) makeRustPlatform;
      mkRust = self.rust.mkRust; };
  };
}

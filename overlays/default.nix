{
  # Add your overlays here
  #
  sources = _: _: { localSources = (import ../default.nix { }).sources; };

  overrides = self: super: {
    toplevel = builtins.toString ./..;
    nvfetcher =
      (import self.localSources.nvfetcher.src).defaultPackage."${self.system}";
    crate2nix = (import self.localSources.crate2nix.src { });

    pkgsPure = import self.localSources.nixpkgs.src { inherit (self) system; };

    # FIXME: for some reason nix wants to rebuild this if taken from the overlay
    inherit (self.pkgsPure) webkitgtk;
  };

  rust-overlay = import ./rust-overlay.nix;
  rust = import ./rust.nix;

  packages = self: super: {
    holochainPackages = self.callPackage ../packages {
      inherit (self) makeRustPlatform;
      mkRust = self.rust.mkRust;
    };
  };
}

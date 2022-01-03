self: super:

{
  rust = super.rust // (let
    extensions = [
      "rust-src"
    ];
    targets = [
      "aarch64-unknown-linux-musl"
      "wasm32-unknown-unknown"
      "x86_64-pc-windows-gnu"
      "x86_64-unknown-linux-musl"
      "x86_64-apple-darwin"
    ];

    mkRust = { track, version }: self.rust-bin."${track}"."${version}".default.override {
      inherit extensions targets;
    };

    rustNightly = mkRust { track = "nightly"; version = "latest"; };
    rustStable = mkRust { track = "stable"; version = "1.55.0"; };

  in {
    inherit mkRust;

    packages = super.rust.packages // {
      nightly = {
        rustPlatform = self.makeRustPlatform {
          rustc = rustNightly;
          cargo = rustNightly;
        };

        inherit (self.rust.packages.nightly.rustPlatform) rust;
      };

      stable = {
        rustPlatform = self.makeRustPlatform {
          rustc = rustStable;
          cargo = rustStable;
        };

        inherit (self.rust.packages.stable.rustPlatform) rust;
      };
    };
  });

  inherit (self.rust.packages.stable.rust) rustc cargo;
}

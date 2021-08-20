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
    ];

    rustNightly = (self.rustChannelOf {
      channel = "nightly";
      date = "2019-11-16";
      sha256 = "17l8mll020zc0c629cypl5hhga4hns1nrafr7a62bhsp4hg9vswd";
    }).rust.override { inherit extensions targets; };

    rustStable = (self.rust-bin.stable."1.54.0".default.override {
      inherit extensions targets;
    });

    # rustStable = (self.rustChannelOf {
    #   channel = "stable";
    # }).rust.override {  };
  in {
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
}

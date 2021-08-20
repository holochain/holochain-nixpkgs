with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "env";
  buildInputs = [
    niv
    nix-build-uncached
  ];
}

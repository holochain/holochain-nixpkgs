{ stdenv, rustPlatform, fetchFromGitHub, lib, darwin, libiconv, xcbuild }:

let
  name = "lair_keystore";
  versionPrefix = "lair_keystore-";
  version = "${versionPrefix}0.0.2";

in rustPlatform.buildRustPackage {
  inherit name version;

  src = fetchFromGitHub {
    owner = "holochain";
    repo = "lair";
    rev = version;
    sha256 = "0xfcglldb0vij1dcw8gpy21szmh6fdywx58sp2ipb42y1x26a5c6";
  };

  cargoSha256 = "0xg4l89lig0i5m0p8xiyqmm08j6x9599vfzzl59a7lg34w1rwv5s";

  nativeBuildInputs = lib.optionals stdenv.isDarwin [ xcbuild ];

  buildInputs = lib.optionals stdenv.isDarwin
    (with darwin.apple_sdk.frameworks; [ AppKit libiconv ]);

  doCheck = false;
}

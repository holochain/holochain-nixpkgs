# TODO: automate updating these
# 1. set all sha256 and cargoSha256 to "0000000000000000000000000000000000000000000000000000"
# 2. try to build
# 3. replace first sha256 with output
# 4. try to build
# 5. replace second sha256 with output
# 6. try to build
# 7. replace first cargoSha256 with output
# 7. try to build
# 8. replace second cargoSha256 with output

{
  develop = {
    rev = "cacb6af9d733bcd782a04a9f4b0a72e520433a6e";
    sha256 = "18lc87z6pmbyzffgpi6b6jcikb44a0c4bmjzvvf7l4dgqmm2xbm6";
    cargoSha256 = "19z2qakhhvwrva16ycq4zpnhl0xhksli8jknfpr1l2sxfbm2zjiw";
    bins = {
      holochain = "holochain";
      hc = "hc";
      kitsune-p2p-proxy = "kitsune_p2p/proxy";
    };

    lairKeystoreHashes = {
      sha256 = "0khg5w5fgdp1sg22vqyzsb2ri7znbxiwl7vr2zx6bwn744wy2cyv";
      cargoSha256 = "1lm8vrxh7fw7gcir9lq85frfd0rdcca9p7883nikjfbn21ac4sn4";
    };
  };

  main = {
    rev = "holochain-0.0.103";
    sha256 = "1z0y1bl1j2cfv4cgr4k7y0pxnkbiv5c0xv89y8dqnr32vli3bld7";
    cargoSha256 = "1rf8vg832qyymw0a4x247g0iikk6kswkllfrd5fqdr0qgf9prc31";
    bins = {
      holochain = "holochain";
      hc = "hc";
      kitsune-p2p-proxy = "kitsune_p2p/proxy";
    };

    lairKeystoreHashes = {
      sha256 = "1jiz9y1d4ybh33h1ly24s7knsqyqjagsn1gzqbj1ngl22y5v3aqh";
      cargoSha256 = "0agykcl7ysikssfwkjgb3hfw6xl0slzy38prc4rnzvagm5wd1jjv";
    };
  };
}

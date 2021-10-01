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
    rev = "18e025ce6572f3a10bc5e4c735ff04d8d72d7825";
    sha256 = "0rac68l536h206ncd51b5m4h1nzii3afr01bhfq20kwrzclyx223";
    cargoSha256 = "1i6i80vf7jjw1h0b3dsh5n0x8g5g3h16sw9rskw84yipqbv51nc7";
    bins = {
      holochain = "holochain";
      hc = "hc";
      kitsune-p2p-proxy = "kitsune_p2p/proxy";
    };

    lairKeystoreHashes = {
      sha256 = "1ibynj1mn1mc59x7b2jn8l1vv9m8czwcvpq81qgbpa52jgjqlf14";
      cargoSha256 = "1dnfjdk3b4l7ysvm81r061mxly889bbcmg2h11nkgmfj79djka9s";
    };
  };

  main = {
    rev = "holochain-0.0.108";
    sha256 = "1p9rqd2d2wlyzc214ia93b1f18fgqspmza863q4hrz9ba6xigzjs";
    cargoSha256 = "0p4m8ckbd7v411wgh14p0iz4dwi84i3cha5m1zgnqlln0wkqsb0f";
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
}

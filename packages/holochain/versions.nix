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
    rev = "a317cbfbf1410548f8352ad70b2d615a659ce2b8";
    sha256 = "1rxqjfc78rjyi28icdiy3mc3722wy9wh5xdk94xij4lv9vxdxkds";
    cargoSha256 = "07bncnb45m82y37p2rdck5vd0hymd9a9vh3h6xmip1cf89fmsa3a";
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
    rev = "holochain-0.0.107";
    sha256 = "1m5clhh0xpr4ajdbybxjqc5vblkd30lsfb1sac4zbzxjrnpp5iki";
    cargoSha256 = "175b76j31sls0gj08imchwnk7n4ylsxlc1bm58zrhfmq62hcchb1";
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

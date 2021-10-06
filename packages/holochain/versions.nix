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
      sha256 = "12n1h94b1r410lbdg4waj5jsx3rafscnw5qnhz3ky98lkdc1mnl3";
      cargoSha256 = "0axr1b2hc0hhik0vrs6sm412cfndk358grfnax9wv4vdpm8bq33m";
    };
  };

  main = {
    rev = "holochain-0.0.109";
    sha256 = "1rwss1y8cd52ccd0875pfpbw6v518vcry3hjc1lja69x2g2x12qb";
    cargoSha256 = "08a72d7nqpakml657z9vla739cbg8y046av4pwisdgj1ykyzyi60";
    bins = {
      holochain = "holochain";
      hc = "hc";
      kitsune-p2p-proxy = "kitsune_p2p/proxy";
    };

    lairKeystoreHashes = {
      sha256 = "12n1h94b1r410lbdg4waj5jsx3rafscnw5qnhz3ky98lkdc1mnl3";
      cargoSha256 = "0axr1b2hc0hhik0vrs6sm412cfndk358grfnax9wv4vdpm8bq33m";
    };
  };
}

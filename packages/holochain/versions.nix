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
    rev = "a411e9dbe0f4a580b8cb44d5b5d7d8dc3d013ac3";
    sha256 = "086wkgd40nib40hi0247ssr894smhp7pzq3q4p1pm6xwzm3j26rd";
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

  main = {
    rev = "holochain-0.0.110";
    sha256 = "1fykfqslr7lhbp11wbl7cz5pmygw9wmhlkvvnfn9ig9ddr7nq6sw";
    cargoSha256 = "11s50qq7719grgijnw2z2wi27xa918ycjnsmcd5a8c2kvf4al3yw";
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

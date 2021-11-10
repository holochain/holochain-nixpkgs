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
    # 0.0.115
    rev = "efd47955adbf381bf9a886b0e0f9146dfd6be46c";
    sha256 = "0krgdv6a01c484a7hy9q5mnzx8vi3jwccb3qwmysnw1mwdykd9a0";
    cargoSha256 = "1nmyk14d1v8y3wipjlff7bn38ay7zkp5fkzr7qbgm28kbai4ji3v";
    bins = {
      holochain = "holochain";
      hc = "hc";
      kitsune-p2p-proxy = "kitsune_p2p/proxy";
    };

    lairKeystoreHashes = {
      sha256 = "06vd1147323yhznf8qyhachcn6fs206h0c0bsx4npdc63p3a4m42";
      cargoSha256 = "0brgy77kx797pjnjhvxhzjv9cjywdi4l4i3mdpqx3kyrklavggcy";
    };
  };
}

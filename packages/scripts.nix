{ pkgs, lib, writeShellScriptBin, writeScriptBin, git, cargo, crate2nix
, nvfetcher

, holochain, toplevel }:

let
  nvfetcher-clean = writeShellScriptBin "nvfetcher-clean" ''
    cd ${toString toplevel}/nix/nvfetcher
    ${nvfetcher}/bin/nvfetcher clean $@
  '';

  nvfetcher-build = writeShellScriptBin "nvfetcher-build" ''
    cd ${toString toplevel}/nix/nvfetcher
    ${nvfetcher}/bin/nvfetcher build $@
  '';

  diffPaths = configKeys:
    builtins.concatStringsSep " " ([
      "${toplevel}/nix/nvfetcher/nvfetcher.toml"
      "${toplevel}/nix/nvfetcher/_sources/generated.json"
    ] ++ (builtins.map
      (configKey: "${toplevel}/packages/holochain/versions/${configKey}.nix")
      configKeys));
  addPaths = configKeys:
    builtins.concatStringsSep " " ([
      "${toplevel}/nix/nvfetcher/nvfetcher.toml"
      "${toplevel}/nix/nvfetcher/_sources/"
    ] ++ (builtins.map
      (configKey: "${toplevel}/packages/holochain/versions/${configKey}.nix")
      configKeys));

in {
  inherit nvfetcher-clean nvfetcher-build;

  hnixpkgs-update-single = writeShellScriptBin "hnixpkgs-update-single" (let
    errMsg = ''
      ERROR: no argument provided.

      Please pass one argument that matches one of the keys in this file:
        ${
          builtins.toString toplevel
        }/packages/holochain/versions/update_config.toml.

      Currently these are:
      ${builtins.concatStringsSep "\n" (builtins.map (key: "- ${key}")
        (builtins.attrNames holochain.holochainVersionUpdateConfig))}
    '';

  in ''
    if [ -z "$1" ]; then
      printf '${errMsg}'
      exit 1
    fi

    ${pkgs.nixUnstable}/bin/nix run --extra-experimental-features nix-command --impure --expr "(import ./default.nix {}).packages.scripts._hnixpkgs-update \"''${1:?}\""
  '');

  nixpkgs-regen-crate-expressions = let
    toplevel = (builtins.toString ./..);
    outputPath = "nix/crate2nix/Cargo.nix";
    diffTargets = "${outputPath} Cargo.lock";
  in writeShellScriptBin "hnixpkgs-regen-crate-expressions" ''
    set -e
    cd ${toplevel}

    ${cargo}/bin/cargo generate-lockfile
    ${crate2nix}/bin/crate2nix generate --default-features --output=${outputPath}

    if git diff --quiet --exit-code -- ${diffTargets}; then
      echo No updates found.
    else
      echo Updates found, commiting..
      git commit ${diffTargets} -m "update generated crate expressions"
    fi
  '';

  hnixpkgs-update-nvfetcher-src =
    writeShellScriptBin "hnixpkgs-update-nvfetcher-src" ''
      set -ex

      cd ${toplevel}

      trap "git checkout ${toplevel}/nix/nvfetcher" ERR INT

      git clean -fd ${toplevel}/nix/nvfetcher/_sources/

      ${nvfetcher-build}/bin/nvfetcher-build --filter $@

      cd ${toplevel}

      trap "" ERR INT

      ${git}/bin/git add ${addPaths [ ]}
      if ! ${git}/bin/git diff --staged --exit-code -- ${diffPaths [ ]}; then
          echo New versions found, commiting..
          ${git}/bin/git commit ${addPaths [ ]} \
            -m "update nvfetcher source: $@"
      fi
    '';

  hnixpkgs-iter = writeScriptBin "hnixpkgs-iter" ''
    set - e
    nix-shell --pure --arg flavors '[ "dev" ]' --run "hnixpkgs-regen-crate-expressions"
    exec nix-shell --pure --arg flavors '[ "dev" "release" ]' --run "$(echo $@)"
  '';
}

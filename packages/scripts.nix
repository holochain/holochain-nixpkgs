{ pkgs
, lib
, writeShellScriptBin
, git
, cargo
, crate2nix
, nvfetcher

, holochain
, update-holochain-versions
, toplevel
}:

let
  nvfetcher-clean = writeShellScriptBin "nvfetcher-clean" ''
    cd ${toString toplevel}/nix/nvfetcher
    ${nvfetcher}/bin/nvfetcher clean $@
  '';

  nvfetcher-build = writeShellScriptBin "nvfetcher-build" ''
    cd ${toString toplevel}/nix/nvfetcher
    ${nvfetcher}/bin/nvfetcher build $@
  '';

  updateSingle = { configKey, cliFlags }: ''
    ${update-holochain-versions}/bin/update-holochain-versions \
      --nvfetcher-dir=${toplevel}/nix/nvfetcher \
      --output-file=${toplevel}/packages/holochain/versions/${configKey}.nix \
      ${builtins.concatStringsSep " " (lib.attrsets.mapAttrsToList
        (cliKey: cliValue: ''--${cliKey}="${cliValue}"'') cliFlags)
      }
  '';

  updateSingle' = configKey: ''
    ${update-holochain-versions}/bin/update-holochain-versions \
      --nvfetcher-dir=${toplevel}/nix/nvfetcher \
      --output-file=${toplevel}/packages/holochain/versions/${configKey}.nix \
      ${builtins.concatStringsSep " " (lib.attrsets.mapAttrsToList
        (cliKey: cliValue: ''--${cliKey}="${cliValue}"'') holochain.holochainVersionUpdateConfig."${configKey}")
      }
  '';

  diffPaths = configKeys:
    builtins.concatStringsSep " " (
      [
        "${toplevel}/nix/nvfetcher/_sources/generated.json"
      ]
      ++ (builtins.map (configKey: "${toplevel}/packages/holochain/versions/${configKey}.nix") configKeys)
    );
  addPaths = configKeys:
    builtins.concatStringsSep " " (
      [
        "${toplevel}/nix/nvfetcher/_sources/"
      ]
      ++ (builtins.map (configKey: "${toplevel}/packages/holochain/versions/${configKey}.nix") configKeys)
    );

  hnixpkgs-update = configKeys: ''
    set -e

    cd ${toplevel}

    trap "git checkout ${toplevel}/nix/nvfetcher" ERR INT

    git clean -fd ${toplevel}/nix/nvfetcher/_sources/

    ${builtins.concatStringsSep "\n"
      (builtins.map
        (configKey: (updateSingle' configKey))
        configKeys
      )
    }

    trap "" ERR INT

    ${git}/bin/git add ${addPaths configKeys}
    if ! ${git}/bin/git diff --staged --exit-code -- ${diffPaths configKeys}; then
        echo New versions found, commiting..
        ${git}/bin/git commit ${addPaths configKeys} \
          -m "update nvfetcher sources" \
          -m "the following keys were updated" \
          -m "${builtins.concatStringsSep " " configKeys}"
    fi
  '';
in

{
  inherit nvfetcher-clean nvfetcher-build;


  _hnixpkgs-update = configKey: writeShellScriptBin "hnixpkgs-update"
    (hnixpkgs-update
      [ configKey ]
    )
  ;

  hnixpkgs-update-single = writeShellScriptBin "hnixpkgs-update-single" (
    let
      errMsg = ''
        ERROR: no argument provided.

        Please pass one argument that matches one of the keys in this file:
          ${builtins.toString toplevel}/packages/holochain/versions/update_config.toml.

        Currently these are:
        ${builtins.concatStringsSep "\n"
          (builtins.map
            (key: "- ${key}")
            (builtins.attrNames holochain.holochainVersionUpdateConfig)
          )
        }
      '';

    in
    ''
      if [ -z "$1" ]; then
        printf '${errMsg}'
        exit 1
      fi

      ${pkgs.nixUnstable}/bin/nix run --extra-experimental-features nix-command --impure --expr "(import ./default.nix {}).packages.scripts._hnixpkgs-update \"''${1:?}\""
    ''
  );

  hnixpkgs-update-all = writeShellScriptBin "hnixpkgs-update-all"
    (hnixpkgs-update
      (builtins.attrNames holochain.holochainVersionUpdateConfig)
    )
  ;

  nixpkgs-regen-crate-expressions =
    let
      toplevel = (builtins.toString ./..);
      outputPath = "nix/crate2nix/Cargo.nix";
      diffTargets = "${outputPath} Cargo.lock";
      buildTargets = "-A packages.update-holochain-versions";
    in
    writeShellScriptBin "hnixpkgs-regen-crate-expressions" ''
      set -e
      cd ${toplevel}

      ${cargo}/bin/cargo generate-lockfile
      ${crate2nix}/bin/crate2nix generate --default-features --output=${outputPath}

      if git diff --exit-code -- ${diffTargets}; then
        echo No updates found.
      else
        nix-build default.nix --no-out-link ${buildTargets}
        echo Updates found, commiting..
        git commit ${diffTargets} -m "update generated crate expressions"
      fi
    '';
  hnixpkgs-update-nvfetcher-src = writeShellScriptBin "hnixpkgs-update-nvfetcher-src" ''
    set -ex

    cd ${toplevel}

    trap "git checkout ${toplevel}/nix/nvfetcher" ERR INT

    git clean -fd ${toplevel}/nix/nvfetcher/_sources/

    ${nvfetcher-build}/bin/nvfetcher-build --filter $@

    cd ${toplevel}

    trap "" ERR INT

    ${git}/bin/git add ${addPaths []}
    if ! ${git}/bin/git diff --staged --exit-code -- ${diffPaths []}; then
        echo New versions found, commiting..
        ${git}/bin/git commit ${addPaths []} \
          -m "update nvfetcher source: $@"
    fi
  '';
}

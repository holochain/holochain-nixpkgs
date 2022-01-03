{ pkgs
, lib
, writeScriptBin
, git
, cargo
, crate2nix
, nvfetcher

, holochain
, update-holochain-versions
, toplevel
}:

let
  nvfetcher-clean = writeScriptBin "nvfetcher-clean" ''
    pushd ${toString toplevel}/nix/nvfetcher
    ${nvfetcher}/bin/nvfetcher clean $@
  '';
in

{
  inherit nvfetcher-clean;

  nvfetcher-build = writeScriptBin "nvfetcher-build" ''
    pushd ${toString toplevel}/nix/nvfetcher
    ${nvfetcher}/bin/nvfetcher build $@
  '';

  hnixpkgs-update-all = writeScriptBin "hnixpkgs-update-all" (
    let
      updateAll = builtins.concatStringsSep "\n" (lib.attrsets.mapAttrsToList
        (key: value:
          let
            extraArgs = builtins.concatStringsSep " " (lib.attrsets.mapAttrsToList
              (key': value': ''--${key'}="${value'}"'')
              value
            );
          in
          ''
            ${update-holochain-versions}/bin/update-holochain-versions \
                --nvfetcher-dir=${toplevel}/nix/nvfetcher \
                --output-file=${toplevel}/packages/holochain/versions/${key}.nix \
                ${extraArgs} \
                ;
          ''
        )
        holochain.holochainVersionUpdateConfig
      );

      diffTargets = "${toplevel}/packages/holochain/versions ${toplevel}/nix/nvfetcher/_sources/generated.nix";
      commitPaths = "${toplevel}/packages/holochain/versions ${toplevel}/nix/nvfetcher";
    in
    ''
      set -e

      pushd ${toplevel}

      trap "git checkout ${toplevel}/nix/nvfetcher" ERR INT
      ${nvfetcher-clean}/bin/nvfetcher-clean

      ${updateAll}

      trap "" ERR INT

      ${git}/bin/git add ${commitPaths}

      if ${git}/bin/git diff --staged --exit-code -- ${diffTargets}; then
          echo No updates found.
      else
          echo Updates found, commiting..
          ${git}/bin/git commit ${commitPaths} -m "update all sources and holochain versions"
      fi
    ''
  );

  nixpkgs-regen-crate-expressions =
    let
      toplevel = (builtins.toString ./..);
      outputPath = "nix/crate2nix/Cargo.nix";
      diffTargets = "${outputPath} Cargo.lock";
      buildTargets = "-A packages.update-holochain-versions";
    in
    writeScriptBin "hnixpkgs-regen-crate-expressions" ''
      set -e
      pushd ${toplevel}

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
}

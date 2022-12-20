{ ... }@args:
(import ./default.nix (builtins.removeAttrs args [ "inNixShell" ]))

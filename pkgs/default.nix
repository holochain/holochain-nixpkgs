{ callPackage, rustPlatform }:

let 
  holochain = callPackage ./holochain { inherit rustPlatform; };
in 
  holochain //
  { }

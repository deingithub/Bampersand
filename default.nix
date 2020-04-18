with import <nixpkgs> {};
crystal.buildCrystalPackage rec {
  version = "0.18.0";
  pname = "Bampersand";
  src = ./.;

  shardsFile = ./shards.nix;
  crystalBinaries.Bampersand.src = "src/Init.cr";

  buildInputs = [ sqlite-interactive.dev ];
}

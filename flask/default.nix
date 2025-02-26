{ pkgs, nixpkgs, nixpkgs-python, system }:
let
    preprocessPackages = import ./preprocess {
        inherit pkgs; inherit system;
        inherit nixpkgs; inherit nixpkgs-python; };
in
{

  flaskApp = pkgs.callPackage ./derivation.nix {preprocessPackage = preprocessPackages.preprocessDerivation; };
  preprocessPackage = preprocessPackages.preprocessDerivation;
}

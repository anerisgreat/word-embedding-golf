{ pkgs, nixpkgs, nixpkgs-python, system, wordEmbGolfGraphPkgs }:
{

  flaskApp = pkgs.callPackage ./derivation.nix {
    wordEmbGolfGraphPkgs = wordEmbGolfGraphPkgs; };
}

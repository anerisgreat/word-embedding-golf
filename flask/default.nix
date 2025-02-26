{ pkgs, nixpkgs, nixpkgs-python, system }:
let
    wordEmbGolfGraphPkgs = import ./word_emb_golf_graph {
        inherit pkgs; inherit system;
        inherit nixpkgs; inherit nixpkgs-python; };
in
{

    flaskApp = pkgs.callPackage ./derivation.nix {wordEmbGolfGraphDrv = wordEmbGolfGraphPkgs.wordEmbGolfGraphDrv; };
    wordEmbGolfGraphPkgs = wordEmbGolfGraphPkgs;
    wordEmbGolfGraphDrv = wordEmbGolfGraphPkgs.wordEmbGolfGraphDrv;
}

{ lib, pkgs, python3Packages, wordEmbGolfGraphPkgs }:
let _internalWordEmbGolfWebapp = with python3Packages; buildPythonApplication {
        pname = "_word_emb_golf_webapp";
        version = "1.0";

        propagatedBuildInputs = [ flask wordEmbGolfGraphPkgs.wordEmbGolfGraphPythonPkg];

        src = ./.;
    };
in pkgs.symlinkJoin {
  name = "word_emb_golf_webapp";
  paths = [_internalWordEmbGolfWebapp];
  buildInputs = [wordEmbGolfGraphPkgs.wordEmbGolfGraphDrv pkgs.makeWrapper];
  postBuild = ''
    wrapProgram $out/bin/web_interface.py --set GRAPH_DATA ${wordEmbGolfGraphPkgs.wordEmbGolfGraphDrv}/graph.pickle
  '';
}

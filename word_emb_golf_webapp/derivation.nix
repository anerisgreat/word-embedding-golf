{ lib, pkgs, python3Packages, wordEmbGolfGraphPythonPkg, wordEmbGolfGraphPreprocessDrv }:
let _internalWordEmbGolfWebapp = with python3Packages; buildPythonApplication {
        pname = "_word_emb_golf_webapp";
        version = "1.0";

        propagatedBuildInputs = [ flask networkx wordEmbGolfGraphPythonPkg];

        src = ./.;
    };
in pkgs.symlinkJoin {
  name = "word_emb_golf_webapp";
  paths = [_internalWordEmbGolfWebapp];
  buildInputs = [wordEmbGolfGraphPreprocessDrv pkgs.makeWrapper];
  postBuild = ''
    wrapProgram $out/bin/web_interface.py --set GRAPH_DATA ${wordEmbGolfGraphPreprocessDrv}/graph.json
  '';
}

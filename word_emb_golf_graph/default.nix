#Output is single Python package
{ pkgs, system, nixpkgs, nixpkgs-python } :
let
    fs = pkgs.lib.fileset;
    wordEmbeddingGolfGraphSourceFiles = fs.unions[
      ./setup.py
      ./__init__.py
      ./word_emb_golf_graph/__init__.py
      ./word_emb_golf_graph/graph.py];
in pkgs.python3Packages.buildPythonPackage{
      name = "word_emb_golf_graph";
      format = "setuptools";
      src = fs.toSource {
            root = ./.;
            fileset = wordEmbeddingGolfGraphSourceFiles;
        };
      propagatedBuildInputs = with pkgs.python3Packages; [
        setuptools
        networkx
        numpy
      ];
}


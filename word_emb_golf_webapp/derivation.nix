{ lib, python3Packages, wordEmbGolfGraphPkgs }:
    with python3Packages; buildPythonApplication {
        pname = "word_emb_golf_webapp";
        version = "1.0";

        propagatedBuildInputs = [ flask wordEmbGolfGraphPkgs.wordEmbGolfGraphPythonPkg];

        src = ./.;
    }

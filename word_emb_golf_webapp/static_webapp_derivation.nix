{ lib, pkgs, python3Packages, wordEmbGolfGraphPythonPkg, wordEmbGolfGraphPreprocessDrv }:
let
  fs = pkgs.lib.fileset;
  srcFiles = fs.unions[
      ./render_webapp.py
      ./word_emb_golf_webapp.html
    ];
in
pkgs.stdenv.mkDerivation rec {
    name = "word-emb-golf-preprocess";
    buildInputs = [
        wordEmbGolfGraphPreprocessDrv
        (pkgs.python3.withPackages (python-pkgs: with python-pkgs; [
            wordEmbGolfGraphPythonPkg
            jinja2
        ]))
    ];
    src = fs.toSource{
        root = ./.;
        fileset = srcFiles;
    };
    #Skip unpack since no sources
    installPhase = ''
        mkdir $out
        python $src/render_webapp.py --graph ${wordEmbGolfGraphPreprocessDrv}/graph.json --template $src/word_emb_golf_webapp.html --output $out/index.html
    '';
}


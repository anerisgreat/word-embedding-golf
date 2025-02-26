{ pkgs, system, nixpkgs, nixpkgs-python } :
let
    gloveFileName = "glove.6B.50d.txt";
    gloveDataDerivation = pkgs.stdenv.mkDerivation {
        name = "glove-data-derivation";
        src = pkgs.fetchzip {
            url = "https://nlp.stanford.edu/data/glove.6B.zip";
            #nix-prefetch-url --unpack <URL> gets hash, then nix hash to-sri --type sha256
            hash = "sha256-LV9rgGNLCqvM9el6SezXyozsrP9w0+kp++gPIXcLjWE=";
            stripRoot = false;
        };
        phases = [ "unpackPhase" "installPhase" ];
        installPhase = ''
            mkdir -p $out
            cp $src/${gloveFileName} $out
        '';
    };
    commonWordsDerivation = pkgs.stdenv.mkDerivation rec {
        name = "common-words-derivation";
        fetchurl = "https://raw.githubusercontent.com/first20hours/google-10000-english/refs/heads/master/google-10000-english-no-swears.txt";
        src = pkgs.fetchurl rec {
            url = fetchurl;
            hash = "sha256-1rPgTxrDC+ZSXUFHQWbAv/KEhuzYxI3LCrnHycwF7YY=";
        };
        dontUnpack = true;
        installPhase = "install -D $src $out/" + builtins.baseNameOf fetchurl;
    };
    fs = pkgs.lib.fileset;
    wordEmbeddingGolfGraphSourceFiles = fs.unions[
      ./setup.py
      ./__init__.py
      ./word_emb_golf_graph/__init__.py
      ./word_emb_golf_graph/embeddings.py
      ./word_emb_golf_graph/graph.py
      ./word_emb_golf_graph/game.py
      ./word_emb_golf_graph/gen_graph.py];
    wordEmbGolfGraphPkg = pkgs.python3Packages.buildPythonPackage{
      name = "word_emb_golf_graph";
      src = fs.toSource {
            root = ./.;
            fileset = wordEmbeddingGolfGraphSourceFiles;
        };
      propagatedBuildInputs = with pkgs.python3Packages; [
        setuptools
        networkx
        numpy
      ];
    };
in
rec {
    wordEmbGolfGraphPythonPkg = wordEmbGolfGraphPkg;
    wordEmbGolfGraphPython = (pkgs.python3.withPackages (python-pkgs: with python-pkgs; [
      wordEmbGolfGraphPkg
        ]));

    wordEmbGolfGraphDrv = pkgs.stdenv.mkDerivation rec {
        name = "word-emb-golf-graph";
        buildInputs = [
            gloveDataDerivation
            commonWordsDerivation
            wordEmbGolfGraphPython
        ];
        #Skip unpack since no sources
        unpackPhase = "true";
        installPhase = ''
            export GLOVE_DATA="${gloveDataDerivation}/${gloveFileName}"
            export COMMON_WORD_DATA="${commonWordsDerivation}/google-10000-english-no-swears.txt"
            mkdir $out
            ${wordEmbGolfGraphPython}/bin/gen_graph $out/graph.pickle
        '';
    };
}


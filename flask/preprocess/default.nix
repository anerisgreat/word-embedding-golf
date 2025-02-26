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
        fetchurl = "https://apiacoa.org/publications/teaching/datasets/google-10000-english.txt";
        src = pkgs.fetchurl rec {
            url = fetchurl;
            hash = "sha256-nJZdOEUm+sxZJg6U+Mz/FYJjP6OFAEq+FFXtRXBirLw=";
            downloadToTemp = true;
            postFetch = "install -D $downloadedFile $out/" + builtins.baseNameOf url;
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
    wordEmbGolfGraphPython = (pkgs.python3.withPackages (python-pkgs: with python-pkgs; [
      wordEmbGolfGraphPkg
        ]));

    preprocessDerivation = pkgs.stdenv.mkDerivation rec {
        name = "word-connection-db-derivation";
        buildInputs = [
            gloveDataDerivation
            commonWordsDerivation
            wordEmbGolfGraphPython
        ];
        #Skip unpack since no sources
        unpackPhase = "true";
        installPhase = ''
            export GLOVE_DATA="${gloveDataDerivation}/${gloveFileName}"
            export COMMON_WORD_DATA="${commonWordsDerivation}/google-10000-english.txt"
            mkdir $out
            ${wordEmbGolfGraphPython}/bin/gen_graph $out/graph.pickle
        '';
    };
}


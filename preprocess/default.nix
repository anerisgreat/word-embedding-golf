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
    preprocessSourceFiles = fs.unions[
      ./src/embeddings.py
      ./src/graph.py
      ./gen_graph.py];
in
rec {
    preprocessPython = (pkgs.python3.withPackages (python-pkgs: with python-pkgs; [
        numpy
        networkx
        ]));

    preprocessDerivation = pkgs.stdenv.mkDerivation rec {
        name = "word-connection-db-derivation";
        buildInputs = [
            gloveDataDerivation
            commonWordsDerivation
            preprocessPython
        ];
        src = fs.toSource {
            root = ./.;
            fileset = preprocessSourceFiles;
        };
        installPhase = ''
            export GLOVE_DATA="${gloveDataDerivation}/${gloveFileName}"
            export COMMON_WORD_DATA="${commonWordsDerivation}/google-10000-english.txt"
            mkdir $out
            python $src/gen_graph.py $out/graph.pickle
        '';
    };
}


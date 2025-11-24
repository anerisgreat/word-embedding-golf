{ pkgs, system, nixpkgs, nixpkgs-python, wordEmbGolfGraphPythonPkg } :
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
    wordEmbeddingGolfPreprocessSourceFiles = fs.unions[
      ./gen_graph.py
    ];
in
pkgs.stdenv.mkDerivation rec {
    name = "word-emb-golf-preprocess";
    buildInputs = [
        gloveDataDerivation
        commonWordsDerivation
        (pkgs.python3.withPackages (python-pkgs: with python-pkgs; [
            wordEmbGolfGraphPythonPkg
            scikit-learn
            networkx
        ]))
    ];
    src = fs.toSource{
        root = ./.;
        fileset = wordEmbeddingGolfPreprocessSourceFiles;
    };
    #Skip unpack since no sources
    installPhase = ''
        export GLOVE_DATA="${gloveDataDerivation}/${gloveFileName}"
        export COMMON_WORD_DATA="${commonWordsDerivation}/google-10000-english-no-swears.txt"
        mkdir $out
        python $src/gen_graph.py $out/graph.json
    '';
}


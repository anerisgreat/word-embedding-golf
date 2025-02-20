#
{
  #https://nix.dev/guides/recipes/python-environment.html
  description = "Python development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-python.url = "github:cachix/nixpkgs-python";
  };

  outputs = { self, nixpkgs, nixpkgs-python }: 
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs { inherit system; };

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
      myPythonWithDeps = (pkgs.python3.withPackages (python-pkgs: with python-pkgs; [
            numpy
            scipy
            # matplotlib
            scikit-learn
            flask
            networkx
          ]));

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
      sourceFiles = fs.unions
        [./word-embedding-golf/src/embeddings.py
        ./word-embedding-golf/src/graph.py
         ./word-embedding-golf/gen_graph.py];
      wordConnectionDBDerivation = pkgs.stdenv.mkDerivation rec {
        name = "word-connection-db-derivation";
        buildInputs = [
          gloveDataDerivation
          commonWordsDerivation
          myPythonWithDeps
        ];
        src = fs.toSource {
          root = ./.;
          fileset = sourceFiles;
        };
        installPhase = ''
         export GLOVE_DATA="${gloveDataDerivation}/${gloveFileName}"
         export COMMON_WORD_DATA="${commonWordsDerivation}/google-10000-english.txt"
         mkdir $out
         python $src/word-embedding-golf/gen_graph.py $out/graph.pickle
        '';
      };

    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          wordConnectionDBDerivation
          myPythonWithDeps
          curl
          jq
        ];

        shellHook = ''
         export GRAPH_DATA="${wordConnectionDBDerivation}/graph.pickle"
        '';
      };
    };
}

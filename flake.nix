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

      wordEmbGolfGraphPythonPkg = import ./word_emb_golf_graph {
        inherit pkgs; inherit nixpkgs; inherit nixpkgs-python; inherit system;
      };

      wordEmbGolfGraphPreprocessDrv = import ./word_emb_golf_preprocess {
        inherit pkgs; inherit nixpkgs; inherit nixpkgs-python; inherit system;
        wordEmbGolfGraphPythonPkg = wordEmbGolfGraphPythonPkg;
      };


      wordEmbGolfWebappPkgs = import ./word_emb_golf_webapp {
        inherit pkgs; inherit nixpkgs;
        inherit nixpkgs-python; inherit system;
        wordEmbGolfGraphPythonPkg = wordEmbGolfGraphPythonPkg;
        wordEmbGolfGraphPreprocessDrv = wordEmbGolfGraphPreprocessDrv;
      };
    in
    rec {
        devShells.${system}.default = pkgs.mkShell {
            buildInputs = with pkgs; [
                (pkgs.python3.withPackages (python-pkgs: with python-pkgs; [
                    numpy
                    networkx
                    scikit-learn
                    flask
                    wordEmbGolfGraphPythonPkg
                ]))

                wordEmbGolfGraphPreprocessDrv
            ];
            shellHook = "export GRAPH_DATA=${wordEmbGolfGraphPreprocessDrv}/graph.json";
        };

      apps.${system}.default = let
          pythonEnv = pkgs.python3;
          serv = pkgs.writeShellApplication {
              # Our shell script name is serve
              # so it is available at $out/bin/serve
              name = "serve";
              # Caddy is a web server with a convenient CLI interface
              runtimeInputs = [pythonEnv wordEmbGolfWebappPkgs.staticWebappDerivation];
              text = ''
              # Serve the current directory on port 8080
              python -m http.server --bind 0.0.0.0 8080 -d ${wordEmbGolfWebappPkgs.staticWebappDerivation}
              '';
          };
      in {
          type = "app";
          # Using a derivation in here gets replaced
          # with the path to the built output
          program = "${serv}/bin/serve";
      };

      packages.${system}.default = wordEmbGolfWebappPkgs.staticWebappDerivation;
    };
}

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

      wordEmbGolfGraphPkgs = import ./word_emb_golf_graph {
        inherit pkgs; inherit nixpkgs; inherit nixpkgs-python; inherit system;
      };

      wordEmbGolfWebappPkgs = import ./word_emb_golf_webapp { inherit pkgs; inherit nixpkgs;
                                         inherit nixpkgs-python; inherit system;
                                         inherit wordEmbGolfGraphPkgs;
                                       };
    in
    {
        devShells.${system}.default = pkgs.mkShell {
            buildInputs = with pkgs; [
                (pkgs.python3.withPackages (python-pkgs: with python-pkgs; [
                    numpy
                    networkx
                    flask
                    wordEmbGolfGraphPkgs.wordEmbGolfGraphPythonPkg
                ]))

                wordEmbGolfGraphPkgs.wordEmbGolfGraphDrv
            ];
            shellHook = "export GRAPH_DATA=${wordEmbGolfGraphPkgs.wordEmbGolfGraphDrv}/graph.pickle";
        };

      flaskApp = wordEmbGolfWebappPkgs.flaskApp;
    };
}

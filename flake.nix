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

      flaskAppOutputs = import ./flask { inherit pkgs; inherit nixpkgs;
                                         inherit nixpkgs-python; inherit system;
                                       };
    in
    {
      devShells.${system} = {
        # preprocessShell = pkgs.mkShell {
        #     buildInputs = with pkgs; [
        #         preprocessPackages.preprocessDerivation
        #         preprocessPackages.preprocessPython
        #     ];

        #     shellHook = ''
        #         export GRAPH_DATA="${preprocessPackages.preprocessDerivation}/graph.pickle"
        #     '';
        # };
        # default = pkgs.mkShell {
        #     buildInputs = with pkgs; [
        #         (pkgs.python3.withPackages (python-pkgs: with python-pkgs; [
        #             numpy
        #             networkx
        #             flask
        #         ]))
        #     ];
        # };

      };
      flaskApp = flaskAppOutputs.flaskApp;
    };
}

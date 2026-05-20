{
  description = "Python development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-python.url = "github:cachix/nixpkgs-python";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-python, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
      let
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
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            (pkgs.python3.withPackages (python-pkgs: with python-pkgs; [
              numpy
              networkx
              scikit-learn
              flask
              pytest
              wordEmbGolfGraphPythonPkg
            ]))
            wordEmbGolfGraphPreprocessDrv
            cloudflared
            qrencode
          ];
          shellHook = "export GRAPH_DATA=${wordEmbGolfGraphPreprocessDrv}/graph.json";
        };

        apps =
          let
            serv = pkgs.writeShellApplication {
              name = "serve";
              runtimeInputs = [ pkgs.python3 ];
              text = ''
                python -m http.server --bind 0.0.0.0 8080 -d ${wordEmbGolfWebappPkgs.staticWebappDerivation}
              '';
            };
            tunnelApp = pkgs.writeShellApplication {
              name = "tunnel";
              runtimeInputs = [ pkgs.python3 pkgs.cloudflared pkgs.qrencode ];
              text = ''
                echo "Starting local server and Cloudflare tunnel..."
                echo ""

                echo "Starting local server on http://localhost:8080..."
                python -m http.server --bind 0.0.0.0 8080 -d ${wordEmbGolfWebappPkgs.staticWebappDerivation} &
                SERVER_PID=$!

                sleep 2

                echo ""
                echo "Starting HTTPS tunnel..."
                echo "Use the QR code below on your device:"
                echo ""

                cloudflared tunnel --url http://localhost:8080 2>&1 | \
                  while IFS= read -r line; do
                    echo "$line"
                    if echo "$line" | grep -q "https://.*trycloudflare.com"; then
                      URL=$(echo "$line" | grep -o "https://[^ ]*trycloudflare.com")
                      echo ""
                      echo "=========================================="
                      echo "TUNNEL URL: $URL"
                      echo "=========================================="
                      echo ""
                      echo "QR Code:"
                      echo ""
                      qrencode -t ANSIUTF8 "$URL"
                      echo ""
                    fi
                  done

                kill $SERVER_PID 2>/dev/null
              '';
            };
          in {
            default = {
              type = "app";
              program = "${serv}/bin/serve";
            };
            tunnel = {
              type = "app";
              program = "${tunnelApp}/bin/tunnel";
            };
          };

        packages.default = wordEmbGolfWebappPkgs.staticWebappDerivation;
      }
    );
}

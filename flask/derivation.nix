{ lib, python3Packages, wordEmbGolfGraphDrv }:
    with python3Packages; buildPythonApplication {
        pname = "demo-flask-vuejs-rest";
        version = "1.0";

        buildInputs = [wordEmbGolfGraphDrv];
        propagatedBuildInputs = [ flask ];

        src = ./.;

        postInstallHook = "ln -s ${wordEmbGolfGraphDrv}/graph.pickle $out/bin/graph.pickle";
    }

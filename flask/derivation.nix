{ lib, python3Packages, preprocessPackage }:
    with python3Packages; buildPythonApplication {
        pname = "demo-flask-vuejs-rest";
        version = "1.0";

        buildInputs = [preprocessPackage];
        propagatedBuildInputs = [ flask ];

        src = ./.;

        # postInstallHook = "ln -s ${preprocessPackage}/graph.pickle $out/bin/graph.pickle";
    }

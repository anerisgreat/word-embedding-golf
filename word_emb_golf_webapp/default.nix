{ pkgs, nixpkgs, nixpkgs-python, system, wordEmbGolfGraphPythonPkg, wordEmbGolfGraphPreprocessDrv}:
{

  flaskApp = pkgs.callPackage ./derivation.nix {
    wordEmbGolfGraphPythonPkg = wordEmbGolfGraphPythonPkg;
    wordEmbGolfGraphPreprocessDrv = wordEmbGolfGraphPreprocessDrv;
  };
}

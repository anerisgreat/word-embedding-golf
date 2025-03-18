{ pkgs, nixpkgs, nixpkgs-python, system, wordEmbGolfGraphPythonPkg, wordEmbGolfGraphPreprocessDrv}:
{

  staticWebappDerivation = pkgs.callPackage ./static_webapp_derivation.nix {
    wordEmbGolfGraphPythonPkg = wordEmbGolfGraphPythonPkg;
    wordEmbGolfGraphPreprocessDrv = wordEmbGolfGraphPreprocessDrv;
  };

}

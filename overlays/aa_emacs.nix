self: super:

rec {
  myEmacsWithPackages = myEpkgs: super.emacsPackagesNg.emacsWithPackages myEpkgs;

  emacs26Env = myEpkgs: super.buildEnv {
    name = "emacs26Env";
    paths = [ (myEmacsWithPackages myEpkgs) ];
  };
}

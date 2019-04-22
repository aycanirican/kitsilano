self: pkgs:
with pkgs;

{
  emacs26Env = epkgs: buildEnv {
    name = "emacs26Env";
    paths = [ (emacsPackagesNg.emacsWithPackages epkgs) ];
  };

  gnupg = gnupg.overrideAttrs (attrs: {
    doCheck = false;
  });
}

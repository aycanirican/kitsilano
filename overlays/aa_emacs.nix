self: pkgs:
with pkgs;

let
  myEmacs = pkgs.emacsMacport;
  emacsWithPackages = (pkgs.emacsPackagesGen myEmacs).emacsWithPackages;
in
{
  emacs26Env = epkgs: buildEnv {
    name = "emacs26Env";
    paths = [ (emacsWithPackages epkgs) ];
  };

  gnupg = gnupg.overrideAttrs (attrs: {
    doCheck = false;
  });
  libpsl = libpsl.overrideAttrs (attrs: {
    doCheck = false;
  });
}

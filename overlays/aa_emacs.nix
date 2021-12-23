self: pkgs:
with pkgs;

let
  myEmacs = pkgs.emacsMacport;
  emacsWithPackages = (pkgs.emacsPackagesGen myEmacs).emacsWithPackages;
in
{
  emacs27Env = epkgs: buildEnv {
    name = "emacs27Env";
    paths = [ (emacsWithPackages epkgs) ];
  };
}

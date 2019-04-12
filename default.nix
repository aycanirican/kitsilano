{ pkgs ? ( import /home/fxr/nixpkgs {
             overlays = [ (import overlays/emacs/emacs.nix) ]; })
}:

with pkgs;
let
  myEmacs          = import ./emacs  { inherit pkgs;         };
  emacsDockerImage = import ./docker { inherit pkgs myEmacs; };
in rec {
  tools.emacs  = myEmacs;
  images.emacs = emacsDockerImage;
}

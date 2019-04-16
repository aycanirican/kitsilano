{ pkgsPath ? <nixpkgs>
}:

let
  pkgs = import pkgsPath {
    overlays = [ (import ./overlays/aa_emacs.nix) ];
  };

in rec {

  # envfunz
  env = { 
    emacs = pkgs.emacs26Env ((import ./conf/emacs.nix) pkgs); 
  };

  # ducker imagez
  images = { 
    emacs = (import ./docker { 
      inherit pkgs; 
      emacsEnv = env.emacs; 
    }).emacsImage;
  };

}

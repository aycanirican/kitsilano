{ pkgsPath ? <nixpkgs>
}:

let
  pkgs = import pkgsPath {
    overlays = [ (import ./overlays/aa_emacs.nix) ];
  };

in rec {

  emacs.package = pkgs.emacs26Env ((import ./conf/emacs.nix) pkgs); 

  emacs.image = (import ./docker { 
                  inherit pkgs;
                  emacsEnv = emacs.package; 
                }).emacsImage;

  emacs.dotfile = pkgs.writeText "dotemacs" (builtins.readFile ./dotemacs);

  emacs.run = pkgs.writeScript "runemacs" ''
    DCKR="${pkgs.docker}/bin/docker"
    if [[ "$MODE" != "development" ]]; then
      $DCKR load < ${emacs.image}
    fi
    $DCKR run -it --rm -v $PWD:/home/user/data -v ${emacs.dotfile}:/home/user/.emacs -v $HOME/.gitconfig:/home/user/.gitconfig emacs:latest
  '';
}

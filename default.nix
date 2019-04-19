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

  emacs.dotfile = pkgs.runCommand "gen_dotemacs" { preferLocalBuild = true; } ''
    mkdir $out
    substitute ${./dotemacs} $out/dotemacs \
      --subst-var-by MU_PATH "${pkgs.mu}/share/emacs/site-lisp/mu4e";
  '';
  
  emacs.run = pkgs.writeScript "runemacs" ''
    DCKR="${pkgs.docker}/bin/docker"
    if [[ "$MODE" != "development" ]]; then
      $DCKR load < ${emacs.image}
    fi
    $DCKR run -it --rm \
      -v $HOME/.kits.el:/home/user/.kits.el \
      -v $HOME/Maildir:/home/user/Maildir \
      -v $PWD:/home/user/data \
      -v "${emacs.dotfile}/dotemacs":/home/user/.emacs \
      -v $HOME/.gitconfig:/home/user/.gitconfig \
      emacs:latest emacs -debug-init
  '';
}

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
      --subst-var-by MU_PATH "${pkgs.mu}";
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
      kitsilano:latest # by default it runs emacs as a user
  '';

  emacs.publish = { image-id ? "0000", new-version ? "0" }: pkgs.writeScript "emacs-publish" ''
    DCKR="${pkgs.docker}/bin/docker"
    $DCKR images -q kitsilano | ${pkgs.gnugrep}/bin/grep ${image-id} 2> /dev/null
    RES=$?
    
    if [[ $RES -eq 0 ]]; then
      $DCKR tag ${image-id} aycanirican/kitsilano:${new-version}
      $DCKR tag ${image-id} aycanirican/kitsilano:latest
      $DCKR push aycanirican/kitsilano
    else
      echo "Image ID not found. Exiting..."
      exit 1
    fi
  '';
}

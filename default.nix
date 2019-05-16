{ pkgsPath ? (builtins.fetchGit {
                name = "nixos-release-19.03";
                url = https://github.com/nixos/nixpkgs-channels;
                ref = "nixos-19.03";
                rev = "f5493bf6145fc5b3b7415fe2dfe14d0310500ebb";
              })
, withContainer ? false
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
    mkdir -p $out/etc/
    substitute ${./dotemacs} $out/etc/dotemacs \
      --subst-var-by DIFF_PATH "${pkgs.diffutils}" \
      --subst-var-by PATCH_PATH "${pkgs.patch}" \
      --subst-var-by MU_PATH "${pkgs.mu}";
  '';

  emacs.runInContainer = pkgs.writeScript "runemacs" ''
    DCKR="${pkgs.docker}/bin/docker"
    if [[ "$MODE" != "development" ]]; then
      $DCKR load < ${emacs.image}
    fi
    $DCKR run -it --rm \
      -v $HOME/.kits.el:/home/user/.kits.el \
      -v $HOME/Maildir:/home/user/Maildir \
      -v $PWD:/home/user/data \
      -v "${emacs.dotfile}/etc/dotemacs":/home/user/.emacs \
      -v $HOME/.gitconfig:/home/user/.gitconfig \
      kitsilano:latest # by default it runs emacs as a user
  '';

  emacs.runInCurrentProfile = pkgs.writeScript "runemacs" ''
    exec ${emacs.package}/bin/emacs --eval "(load \"${emacs.dotfile}/etc/dotemacs\")" $@
  '';

  emacs.run = if withContainer then emacs.runInContainer else emacs.runInCurrentProfile;

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

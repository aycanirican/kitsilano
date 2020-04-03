{ pkgs
, dockerImages
, constants
}:

let
    dotfile = pkgs.runCommand "gen_dotemacs" { preferLocalBuild = true; } ''
      mkdir -p $out/etc/
      substitute ${./dotemacs} $out/etc/dotemacs \
        --subst-var-by DIFF_PATH    "${pkgs.diffutils}" \
        --subst-var-by PATCH_PATH   "${pkgs.patch}" \
        --subst-var-by MU_PATH      "${pkgs.mu}" \
        --subst-var-by DHALL_PATH   "${pkgs.dhall}" \
        --subst-var-by RG_PATH      "${pkgs.ripgrep}" \
        --subst-var-by HLEDGER_PATH "${pkgs.hledger}"
    '';
    pathRest = with pkgs; "${mu}/bin:${dhall}/bin:${ripgrep}/bin:${hledger}/bin:${hledger-ui}/bin:${hledger-web}/bin";
    myEmacs = pkgs.emacs26Env ((import ./conf/emacs.nix) pkgs);
    runInContainer = "${myEmacs}/bin/emacs";
    runInCurrentProfile = ''
      PATH="$PATH:${pathRest}"
      exec ${myEmacs}/bin/emacs --eval "(load \"${dotfile}/etc/dotemacs\")" $@
    '';
in

rec {
  name  = "emacs";
  image = dockerImages.emacs {
    entrypoint = runInContainer;
    paths      = pathRest;
  };
  
  run          = pkgs.writeScript "run-emacs" runInCurrentProfile;
  runContainer = pkgs.writeScript "run-emacs-in-docker" ''
    DCKR="${pkgs.docker}/bin/docker"
    $DCKR load < ${image}
    $DCKR run -it --rm \
      -v $HOME/.kits.el:/home/user/.kits.el \
      -v $HOME/Maildir:/home/user/Maildir \
      -v $HOME/.hledger.journal:/home/user/.hledger.journal \
      -v $PWD:/home/user/data \
      -v "${dotfile}/etc/dotemacs":/home/user/.emacs \
      -v $HOME/.gitconfig:/home/user/.gitconfig \
      ${name}:latest
  '';
  
  publish = dockerImages.publish { inherit name image constants; };
}

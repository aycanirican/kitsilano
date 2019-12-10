{ pkgs, isContainer, dockerImages }:
let
    dotfile = pkgs.runCommand "gen_dotemacs" { preferLocalBuild = true; } ''
      mkdir -p $out/etc/
      substitute ${./dotemacs} $out/etc/dotemacs \
        --subst-var-by DIFF_PATH "${pkgs.diffutils}" \
        --subst-var-by PATCH_PATH "${pkgs.patch}" \
        --subst-var-by MU_PATH "${pkgs.mu}" \
        --subst-var-by DHALL_PATH "${pkgs.dhall}" \
        --subst-var-by RG_PATH "${pkgs.ripgrep}"
    '';
    myEmacs = pkgs.emacs26Env ((import ./conf/emacs.nix) pkgs);
    runInContainer = ''
      ${myEmacs}/bin/emacs
    '';
    runInCurrentProfile = '' 
      exec ${myEmacs}/bin/emacs --eval "(load \"${dotfile}/etc/dotemacs\")" $@
    '';
in

rec {
  name = "emacs";
  image = dockerImages.emacs run;
  run = pkgs.writeScript "run-emacs" (if isContainer
                                       then runInContainer
                                       else runInCurrentProfile);
  runContainer = assert (isContainer == true); pkgs.writeScript "run-emacs" ''
    DCKR="${pkgs.docker}/bin/docker"
    $DCKR load < ${image}
    $DCKR run -it --rm \
      -v $HOME/.kits.el:/home/user/.kits.el \
      -v $HOME/Maildir:/home/user/Maildir \
      -v $PWD:/home/user/data \
      -v "${dotfile}/etc/dotemacs":/home/user/.emacs \
      -v $HOME/.gitconfig:/home/user/.gitconfig \
      ${name}:latest
  '';
  
  publish = { image-id ? "0000", new-version ? "0" }: pkgs.writeScript "emacs-publish" ''
    DCKR="${pkgs.docker}/bin/docker"
    $DCKR images -q ${name} | ${pkgs.gnugrep}/bin/grep ${image-id} 2> /dev/null
    RES=$?

    if [[ $RES -eq 0 ]]; then
      $DCKR tag ${image-id} aycanirican/${name}:${new-version}
      $DCKR tag ${image-id} aycanirican/${name}:latest
      $DCKR push aycanirican/${name}
    else
      echo "Image ID not found. Exiting..."
      exit 1
    fi
  '';
}

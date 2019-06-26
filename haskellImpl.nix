{ pkgs, isContainer }:
let
    myHaskell = pkgs.haskellPackages.ghcWithPackages (p: with p; [aeson text aeson-pretty]);
    dockerImages = import ./docker { inherit pkgs; };
    
    runInContainer = "${myHaskell}/bin/ghci";
    runInCurrentProfile = "exec ${myHaskell}/bin/ghci"
in

rec {
  name = "haskell";
  
  image = dockerImages.haskell run;
  
  run = pkgs.writeScript "run-haskell" (if isContainer
                                       then runInContainer
                                       else runInCurrentProfile);

  runContainer = assert (isContainer == true); pkgs.writeScript "run-haskell" ''
    DCKR="${pkgs.docker}/bin/docker"
    $DCKR load < ${image}
    $DCKR run -it --rm \
      -v $PWD:/home/user/data \
      -v $HOME/.gitconfig:/home/user/.gitconfig \
      ${name}:latest
  '';
  publish = { image-id ? "0000", new-version ? "0" }: pkgs.writeScript "haskell-publish" ''
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

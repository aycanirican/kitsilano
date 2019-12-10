{ pkgs
, isContainer
, dockerImages 
}:

let
    bin = "${pkgs.selenium-server-standalone}/bin/selenium-server";
    runInContainer = ''
      ${bin}
    '';
    runInCurrentProfile = '' 
      exec ${bin}
    '';
in

rec {
  name = "selenium";
  image = dockerImages.selenium run;
  run = pkgs.writeScript "run-selenium" (if isContainer
                                          then runInContainer
                                          else runInCurrentProfile);
  runContainer = assert (isContainer == true); pkgs.writeScript "run-selenium" ''
    DCKR="${pkgs.docker}/bin/docker"
    $DCKR load < ${image}
    $DCKR run -it --rm \
      -p 4444:4444 \
      -v $PWD:/home/user/data \
      ${name}:latest
  '';
  publish = { image-id ? "0000", new-version ? "0" }: pkgs.writeScript "selenium-publish" ''
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

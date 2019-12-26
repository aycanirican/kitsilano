{ pkgs
, dockerImages 
, constants
}:

let
    bin = "${pkgs.selenium-server-standalone}/bin/selenium-server";
    runInContainer      = "${bin}";
    runInCurrentProfile = "exec ${bin}";
in

rec {
  name  = "selenium";
  image = dockerImages.selenium { 
    entrypoint = runInContainer; 
    paths = [];
  };
  run   = runInCurrentProfile;
  runContainer = pkgs.writeScript "run-selenium-in-docker" ''
    DCKR="${pkgs.docker}/bin/docker"
    $DCKR load < ${image}
    $DCKR run -it --rm \
      -p 4444:4444 \
      -v $PWD:/home/user/data \
      ${name}:latest
  '';
  publish = dockerImages.publish { inherit name image constants; };
}

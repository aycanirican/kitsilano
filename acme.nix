{ pkgs
, dockerImages
, constants
}:

with pkgs;

let
    runInContainer = "${plan9port}/bin/9 acme";
    runInCurrentProfile = ''
      exec ${plan9port}/bin/9 acme
    '';
in

rec {
  name  = "acme";
  image = dockerImages.acme {
    entrypoint = runInContainer;
  };
  
  run          = pkgs.writeScript "run-acme" runInCurrentProfile;
  runContainer = pkgs.writeScript "run-acme-in-docker" ''
    DCKR="${pkgs.docker}/bin/docker"
    $DCKR load < ${image}
    $DCKR run -it --rm \
      -v $PWD:/home/user/data \
      ${name}:latest
  '';
  
  publish = dockerImages.publish { inherit name image constants; };
}

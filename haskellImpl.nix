{ pkgs
, dockerImages
, constants
, compiler ? "ghc865"
, haskellPackages ? import ./conf/haskellPackages.nix { inherit pkgs; }
}:

let
  myHaskell           = pkgs.haskell.packages.${compiler}.ghcWithPackages haskellPackages;
  runInContainer      = "${myHaskell}/bin/ghc";
  runInCurrentProfile = "exec ${myHaskell}/bin/ghc $@";
in

rec {
  name  = "haskell";
  image = dockerImages.haskell {
    entrypoint = runInContainer;
    paths      = "${myHaskell}/bin";
  };
  
  run          = pkgs.writeScript "run-haskell" runInCurrentProfile;
  runContainer = pkgs.writeScript "run-haskel-in-docker" ''
    DCKR="${pkgs.docker}/bin/docker"
    $DCKR load < ${image}
    $DCKR run -it --rm \
      -v $PWD:/home/user/data \
      -v $HOME/.gitconfig:/home/user/.gitconfig \
      ${name}:latest
  '';

  publish = dockerImages.publish { inherit name image constants; };
}

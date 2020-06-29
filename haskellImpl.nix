{ pkgs
, dockerImages
, constants
, compiler ? "ghc8101"
, haskellPackages ? import ./conf/haskellPackages.nix { inherit pkgs; }
}:

let
  libraries = with pkgs; [ zlib ncurses curl libffi ];

  myHaskell           = pkgs.haskell.packages.${compiler}.ghcWithPackages haskellPackages;
  runInContainer      = "${myHaskell}/bin/ghc";
  # runInCurrentProfile = "exec ${myHaskell}/bin/ghc $@";
  runInCurrentProfile = ''
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.lib.makeLibraryPath libraries}
    export C_INCLUDE_PATH=${pkgs.lib.makeSearchPathOutput "dev" "include" libraries}
    export PATH=$PATH:${myHaskell}/bin:${pkgs.cabal-install}/bin
    ${pkgs.bashInteractive}/bin/bash
  '';

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

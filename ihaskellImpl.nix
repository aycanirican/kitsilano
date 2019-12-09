{ pkgs, isContainer }:
let
    ihaskellSrc = builtins.fetchTarball {
      url = "https://github.com/gibiansky/IHaskell/tarball/a442c0b6d4cf1fb17eaa3bf2827f04b21ad334bf";
      sha256 = "0fprbj4g02wn8600siwy4wizz8qx4imsvlvkr36p2ndmrpsynbbl";
    };

    ihaskell = import "${ihaskellSrc}/release.nix" {
      nixpkgs = pkgs;
      compiler = "ghc865";
      packages = self: with self; [ 
        ihaskell-aeson ihaskell-juicypixels ihaskell-blaze ihaskell-diagrams
        ihaskell-gnuplot
      ];
    };

    dockerImages        = import ./docker { inherit pkgs; };
    runInContainer      = "${ihaskell}/bin/ihaskell-notebook --ip 127.0.0.1";
    runInCurrentProfile = "exec ${ihaskell}/bin/ihaskell-notebook --ip 127.0.0.1";
in

rec {
  name = "ihaskell";
  
  image = dockerImages.ihaskell run;
  
  run = pkgs.writeScript "run-ihaskell" (if isContainer
                                          then runInContainer
                                          else runInCurrentProfile);

  runContainer = assert (isContainer == true); pkgs.writeScript "run-ihaskell" ''
    DCKR="${pkgs.docker}/bin/docker"
    $DCKR load < ${image}
    $DCKR run -it --rm \
      -v $PWD:/home/user/data \
      -v $HOME/.gitconfig:/home/user/.gitconfig \
      ${name}:latest
  '';
  publish = { image-id ? "0000", new-version ? "0" }: pkgs.writeScript "ihaskell-publish" ''
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

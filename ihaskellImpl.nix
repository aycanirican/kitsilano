{ pkgs
, dockerImages 
, constants
, haskellPackages ? import ./conf/haskellPackages.nix { inherit pkgs; }
}:

let
    ihaskellSrc = builtins.fetchTarball {
      url = "https://github.com/gibiansky/IHaskell/tarball/a442c0b6d4cf1fb17eaa3bf2827f04b21ad334bf";
      sha256 = "0fprbj4g02wn8600siwy4wizz8qx4imsvlvkr36p2ndmrpsynbbl";
    };
    
    ihaskellPackages = hp: with hp; ([
        ihaskell-aeson ihaskell-juicypixels ihaskell-blaze ihaskell-diagrams
        ihaskell-gnuplot
    ] ++ (haskellPackages hp));
    
    ihaskell = import "${ihaskellSrc}/release.nix" {
      nixpkgs = pkgs;
      compiler = "ghc865";
      packages = ihaskellPackages;
    };

    runInContainer      =      "${ihaskell}/bin/ihaskell-notebook --ip 0.0.0.0";
    runInCurrentProfile = "exec ${ihaskell}/bin/ihaskell-notebook --ip 127.0.0.1";
in

rec {
  name  = "ihaskell";  
  image = dockerImages.ihaskell {
    entrypoint = runInContainer;
    paths      = "${ihaskell}/bin";
  };
  
  run          = pkgs.writeScript "run-ihaskell" runInCurrentProfile;
  runContainer = pkgs.writeScript "run-ihaskell-in-docker" ''
    DCKR="${pkgs.docker}/bin/docker"
    $DCKR load < ${image}
    $DCKR run -it --rm \
      -v $PWD:/home/user/data \
      -v $HOME/.gitconfig:/home/user/.gitconfig \
      ${name}:latest
  '';
  
  publish = dockerImages.publish { inherit name image constants; };
}

{ pkgs
, dockerImages 
, constants
, haskellPackages ? import ./conf/haskellPackages.nix { inherit pkgs; }
}:

let
  sources = import ./nix/sources.nix;
  
  ihaskellPackages = hp: with hp; ([
      ihaskell-aeson ihaskell-juicypixels ihaskell-blaze ihaskell-diagrams
      ihaskell-gnuplot
  ] ++ (haskellPackages hp));
  
  ihaskell = import "${sources.IHaskell}/release.nix" {
    nixpkgs = pkgs;
    compiler = "ghc8102";
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

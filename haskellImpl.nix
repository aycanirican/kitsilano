{ pkgs
, isContainer
, compiler ? "ghc865"
  # takes packagelist, returns sub-list of packages
  # using:
  #   `csvsort -c 2 revdeps.csv | tail -n 200 | csvcut -c "1" | xargs`   
, myHaskellPackages ? (p: with p; [
  
  base bytestring containers text mtl transformers directory
  QuickCheck time filepath aeson hspec vector unordered-containers
  template-haskell process tasty deepseq lens random array HUnit
  parsec network binary tasty-hunit stm attoparsec hashable http-types
  exceptions optparse-applicative criterion tasty-quickcheck Cabal
  semigroups unix data-default test-framework ghc-prim split doctest
  utf8-string conduit pretty async http-client resourcet
  test-framework-hunit wai monad-control test-framework-quickcheck2
  cereal old-locale primitive scientific safe transformers-base
  base64-bytestring network-uri temporary syb tagged warp http-conduit
  case-insensitive cmdargs http-client-tls quickcheck-instances
  old-time yaml blaze-builder data-default-class blaze-html HTTP
  ansi-terminal lifted-base conduit-extra servant ghc either
  pipes hedgehog parallel cryptonite gogol-core zlib haskell-src-exts
  uuid bifunctors amazonka-core MissingH profunctors free monad-logger
  gtk memory dlist microlens megaparsec hslogger wai-extra base-compat
  semigroupoids base16-bytestring aeson-pretty MonadRandom
  amazonka-test contravariant linear ansi-wl-pprint Glob
  transformers-compat cryptohash haskeline mwc-random errors
  file-embed safe-exceptions OpenGL extra utility-ht regex-posix
  wreq servant-server regex-compat monad-loops blaze-markup colour xml
  comonad system-filepath regex-tdfa hxt tagsoup fgl unliftio-core
  strict persistent hmatrix smallcheck clock http-media websockets
  lens-aeson JuicyPixels yesod-core uniplate constraints cairo mmorph
  http-api-data tasty-golden glib ghc-paths foldl xml-conduit
  tasty-smallcheck servant-client resource-pool protolude pretty-show
  haskell-src-meta unliftio singletons postgresql-simple
  string-conversions snap-core cassava vector-space io-streams
  base-unicode-symbols shakespeare base-prelude void unix-compat
  prettyprinter tasty-th tasty-hspec pandoc hspec-expectations
  fast-logger hlint diagrams-lib scotty integer-gmp
  extensible-exceptions cabal-doctest hspec-core json configurator
  streaming GLUT SHA HDBC bindings-DSL
  
  ])
}:

let
    dockerImages = import ./docker { inherit pkgs; };
    
    myHaskell           = pkgs.haskell.packages.${compiler}.ghcWithPackages myHaskellPackages;
    runInContainer      = "${myHaskell}/bin/ghc";
    runInCurrentProfile = "exec ${myHaskell}/bin/ghc $@";
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

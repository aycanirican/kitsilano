# mostly output of (most used packages):
#   `csvsort -c 2 revdeps.csv | tail -n 200 | csvcut -c "1" | xargs`   

{ pkgs }:

let 
  lib = pkgs.haskell.lib;
in

hp: with hp; [
  
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
  ansi-terminal lifted-base conduit-extra servant ghc either pipes
  hedgehog parallel cryptonite gogol-core zlib haskell-src-exts uuid
  bifunctors amazonka-core MissingH profunctors free monad-logger gtk
  memory dlist microlens megaparsec hslogger wai-extra base-compat
  semigroupoids base16-bytestring aeson-pretty MonadRandom
  amazonka-test contravariant linear ansi-wl-pprint Glob
  transformers-compat cryptohash haskeline mwc-random errors
  file-embed safe-exceptions extra utility-ht regex-posix wreq
  servant-server regex-compat monad-loops blaze-markup colour xml
  comonad system-filepath regex-tdfa hxt tagsoup fgl unliftio-core
  strict persistent hmatrix smallcheck clock websockets
  lens-aeson JuicyPixels yesod-core uniplate constraints mmorph
  http-api-data tasty-golden glib ghc-paths foldl xml-conduit
  tasty-smallcheck servant-client resource-pool protolude pretty-show
  haskell-src-meta unliftio singletons postgresql-simple
  string-conversions snap-core cassava vector-space io-streams
  base-unicode-symbols shakespeare base-prelude void unix-compat
  prettyprinter tasty-th tasty-hspec pandoc hspec-expectations
  fast-logger hlint scotty integer-gmp
  extensible-exceptions cabal-doctest hspec-core json configurator
  streaming SHA HDBC curl zlib cabal-install

] ++ [ ad 
     ]

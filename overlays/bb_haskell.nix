se: su:
{
  haskell = su.haskell // {
    packages = su.haskell.packages // {
      ghc8101 = su.haskell.packages.ghc8101.override {
        overrides = self: super: with su.haskell.lib; {
          active        = doJailbreak super.active;
          http-media    = doJailbreak super.http-media;
          monoid-extras = doJailbreak super.monoid-extras;
          protolude     = doJailbreak super.protolude;
          size-based    = doJailbreak super.size-based;
          servant       = doJailbreak (dontCheck super.servant);
          servant-client = doJailbreak super.servant-client;
          servant-server = doJailbreak super.servant-server;
          servant-client-core = doJailbreak super.servant-client-core;
          dual-tree = doJailbreak super.dual-tree;
        };
      };
    };
  };
}

let
  
  sources = import ./nix/sources.nix;
  
  pkgs = import sources.nixpkgs {
    config = { allowUnfree = true;
               allowBroken = true;
             };
    overlays = [
      (_: _: { inherit sources; })
      (import ./overlays/aa_emacs.nix)
      # (import ./overlays/bb_haskell.nix)
    ];
  };

  dockerImages = import ./docker { inherit pkgs; };
  
  constants    = { dockerAccount = "triloxy"; };

  ghc = "ghc921";

in

{ 
  ihaskell = import ./ihaskellImpl.nix { inherit pkgs dockerImages constants; compiler = ghc; };
  haskell  = import ./haskellImpl.nix  { inherit pkgs dockerImages constants; compiler = ghc; };
  emacs    = import ./emacsImpl.nix    { inherit pkgs dockerImages constants; };
  acme     = import ./acme.nix         { inherit pkgs dockerImages constants; };
  selenium = import ./seleniumImpl.nix { inherit pkgs dockerImages constants; };
  # nixops = import ./nixopsImpl.nix   { inherit pkgs dockerImages constants; };
}

let
  
  sources = import ./nix/sources.nix;
  
  pkgs = import sources.nixpkgs {
    config = { allowUnfree = true;
               allowBroken = true;
             };
    overlays = [
      (_: _: { inherit sources; })
      (import ./overlays/aa_emacs.nix)
    ];
  };

  dockerImages = import ./docker { inherit pkgs; };
  
  constants    = { dockerAccount = "triloxy"; };

in

{ 
  ihaskell = import ./ihaskellImpl.nix { inherit pkgs dockerImages constants; };
  haskell  = import ./haskellImpl.nix  { inherit pkgs dockerImages constants; };
  emacs    = import ./emacsImpl.nix    { inherit pkgs dockerImages constants; };
  selenium = import ./seleniumImpl.nix { inherit pkgs dockerImages constants; };
  # nixops   = import ./nixopsImpl.nix   { inherit pkgs dockerImages constants; };}
  qcompile = import ./qcompileImpl.nix { inherit pkgs dockerImages constants; };
}

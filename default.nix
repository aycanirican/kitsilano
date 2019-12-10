{ pkgsPath ? builtins.fetchTarball (import ./nixpkgs.nix)
, isContainer ? false
, system ? builtins.currentSystem
}:

let
  pkgs         = import ./pkgs.nix { nixpkgs = pkgsPath; };
  dockerImages = import ./docker { inherit pkgs; };
in { 
  ihaskell = import ./ihaskellImpl.nix { inherit pkgs dockerImages isContainer; };
  haskell  = import ./haskellImpl.nix  { inherit pkgs dockerImages isContainer; };
  emacs    = import ./emacsImpl.nix    { inherit pkgs dockerImages isContainer; };
  selenium = import ./seleniumImpl.nix { inherit pkgs dockerImages isContainer; };
}

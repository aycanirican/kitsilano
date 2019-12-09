{ pkgsPath ? builtins.fetchTarball (import ./nixpkgs.nix)
, isContainer ? false
, system ? builtins.currentSystem
}:

let
  pkgs         = import ./pkgs.nix { nixpkgs = pkgsPath; };
  dockerImages = import ./docker { inherit pkgs; };
in rec {
  ihaskell = import ./ihaskellImpl.nix { inherit pkgs isContainer; };
  haskell  = import ./haskellImpl.nix  { inherit pkgs isContainer; };
  emacs    = import ./emacsImpl.nix    { inherit pkgs isContainer; };
  selenium = import ./seleniumImpl.nix { inherit pkgs isContainer; };
}

{ pkgsPath ? builtins.fetchTarball (import ./nixpkgs.nix)
, system   ? builtins.currentSystem
}:

let
  pkgs         = import ./pkgs.nix { nixpkgs = pkgsPath; };
  dockerImages = import ./docker { inherit pkgs; };
  constants    = { dockerAccount = "triloxy"; };
in { 
  ihaskell = import ./ihaskellImpl.nix { inherit pkgs dockerImages constants; };
  haskell  = import ./haskellImpl.nix  { inherit pkgs dockerImages constants; };
  emacs    = import ./emacsImpl.nix    { inherit pkgs dockerImages constants; };
  selenium = import ./seleniumImpl.nix { inherit pkgs dockerImages constants; };
}

{ pkgsPath ? builtins.fetchTarball (import ./nixpkgs.nix)
, isContainer ? false
}:

let
  pkgs         = import ./pkgs.nix { nixpkgs = pkgsPath; };
  dockerImages = import ./docker { inherit pkgs; };
in rec {
  emacs    = import ./emacsImpl.nix    { inherit pkgs isContainer; };
  selenium = import ./seleniumImpl.nix { inherit pkgs isContainer; };
}

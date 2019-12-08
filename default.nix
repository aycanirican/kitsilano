{ pkgsPath ? (builtins.fetchGit {
                name = "nixos-release-19.09";
                url = https://github.com/nixos/nixpkgs-channels;
                ref = "nixos-19.09";
              })
, isContainer ? false
, system ? builtins.currentSystem
}:

let
  pkgs = import pkgsPath {
    inherit system;    
    overlays = [ (import ./overlays/aa_emacs.nix) ];
  };
in rec {
  ihaskell = import ./ihaskellImpl.nix { inherit pkgs isContainer; };
  haskell  = import ./haskellImpl.nix  { inherit pkgs isContainer; };
  emacs    = import ./emacsImpl.nix    { inherit pkgs isContainer; };
  selenium = import ./seleniumImpl.nix { inherit pkgs isContainer; };
}

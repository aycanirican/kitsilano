{ pkgsPath ? (builtins.fetchGit {
                name = "nixos-release-19.09";
                url = https://github.com/nixos/nixpkgs-channels;
                ref = "nixos-19.09";
              })
, isContainer ? false
}:

let
  pkgs         = import pkgsPath { overlays = [ (import ./overlays/aa_emacs.nix) ]; };
  dockerImages = import ./docker { inherit pkgs; };
in rec {
  emacs    = import ./emacsImpl.nix    { inherit pkgs isContainer; };
  selenium = import ./seleniumImpl.nix { inherit pkgs isContainer; };
}

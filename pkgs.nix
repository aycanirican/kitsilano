{ nixpkgs ? builtins.fetchTarball (import ./nixpkgs.nix) }:

import nixpkgs {
  overlays = [ (import ./overlays/aa_emacs.nix) ];
  config = {
    
    allowUnfree = true;
    allowBroken = true;

    packageOverrides =
      super: let self = super.pkgs; in {
                   # foo = super.foo;
                 };
  };
}
  

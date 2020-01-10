{ nixpkgs ? builtins.fetchTarball (import ./nixpkgs.nix) }:

let
  lorriSrc = builtins.fetchTarball https://github.com/target/lorri/archive/rolling-release.tar.gz;
in 
import nixpkgs {
  overlays = [ (import ./overlays/aa_emacs.nix) ];
  config = {
    
    allowUnfree = true;
    allowBroken = true;

    packageOverrides =
      super: let self = super.pkgs; in {
                   lorri = super.callPackage lorriSrc {};
                 };
  };
}
  

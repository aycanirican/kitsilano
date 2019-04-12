{ pkgs }:

let
  overrides = self: super: rec {
    counsel            = self.melpaPackages.counsel;
    counsel-projectile = self.melpaPackages.counsel-projectile;
    ivy                = self.melpaPackages.ivy;
    projectile         = self.melpaPackages.projectile;
    swiper             = self.melpaPackages.swiper;
    magit              = self.melpaPackages.magit;
    use-package        = self.melpaPackages.use-package;
    haskell-mode       = self.melpaPackages.haskell-mode;
    org                = self.melpaPackages.org;
  };
  
in ((pkgs.emacsPackagesNgGen pkgs.emacs).overrideScope' overrides).emacsWithPackages (epkgs: with epkgs; [
    ace-jump-mode
    counsel
    counsel-projectile
    diminish
    dockerfile-mode
    editorconfig
    feature-mode
    go-mode
    haskell-mode
    htmlize
    ivy
    magit
    markdown-mode
    nix-mode
    powerline
    projectile
    request
    sass-mode
    terraform-mode
    undo-tree
    use-package
    web-mode
    xterm-color
    yaml-mode
    yasnippet
  ])

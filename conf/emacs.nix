pkgs: epkgs: with epkgs;
[
  ace-jump-mode
  ace-window
  auctex
  auto-yasnippet
  avy
  avy-zap
  counsel
  counsel-projectile
  dante
  diminish
  direnv
  docker
  dockerfile-mode
  editorconfig
  exec-path-from-shell
  feature-mode
  flycheck
  flycheck-haskell
  git-timemachine
  go-autocomplete
  go-mode
  go-rename
  haskell-mode
  hi2
  htmlize
  ivy
  ivy-hydra
  magit
  markdown-mode
  mmm-mode
  multiple-cursors
  nix-mode
  org
  org-mime
  pdf-tools
  powerline
  projectile
  projectile
  request
  rjsx-mode
  sass-mode
  swiper
  terraform-mode
  undo-tree
  use-package
  web-mode
  wgrep
  xterm-color
  yaml-mode
  yasnippet
] ++ (with pkgs; [ 
  curl.dev
  diffutils 
  direnv 
  findutils 
  git
  gnupg 
  isync
  libpcap
  mu
  ripgrep
  silver-searcher 
  zlib.dev
  ])

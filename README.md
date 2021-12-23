# Kitsilano
Portable Development Environment for myself

## For practical users

Kitsilano project provides below tools pre-configured and ready to run
as simple as possible.

  - Latest Stable GHC compiler

  - Emacs 27.2 (has lots of tools already configured, use `$HOME/.kits.el`
    to override default configuration)
	
  - iHaskell jupyter notebook (along with a few ihaskell packages like
    aeson, gnuplot, juicypixels etc...)

There are two possible ways to execute each tool. 

  - NixOS: Run them in your current profile (optional: use cachix)
  - Docker: Build a docker image or use pre-built images

If you're using NixOS, you can execute tools by simply Abuilding it
since Nix already provides isolation. If you don't have NixOS, you can
build a docker image and use your own docker server.

### Run In in NixOS
~~~
# Run ghc interpreter
$(nix-build -A haskell.run) --interactive

# Run Emacs with arguments you like:
$(nix-build -A emacs.run) -nw

# Run ihaskell jupyter notebook which listens on 8888
$(nix-build -A ihaskell.run)
~~~

### Execute in docker container
~~~
# GHCi with most popular packages included
$(nix-build -A haskell.runContainer) --interactive

#ihaskell
$(nix-build -A ihaskell.runContainer)

# emacs
$(nix-build -A emacs.run --argstr withContainer true)

~~~

### Run prebuilt container image (skip loading generated image)
~~~
MODE=development $(nix-build -A emacs.run)
~~~

### Using as an overlay
If you're using NixOS or Nix package manager, you can use this
repository's overlays directory and get advantage of nix overlays.

TODO: write how to use overlays...

## For developers

### Publishing new versions via docker hub

~~~
$(nix-build -A emacs.publish --argstr pkgsPath ~/nixpkgs --argstr image-id 123456789 --argstr new-version --argstr withContainer true)
~~~

# Kitsilano
Portable Development Environment for myself

## Quickly run raw EMACS (v26.2)
Registry: https://cloud.docker.com/repository/docker/aycanirican/kitsilano
~~~
docker pull aycanirican/kitsilano
docker run -it --rm -v $PWD:/home/user/data emacs:latest
~~~

## Run Kits
~~~
$(nix-build -A emacs.run [--argstr pkgsPath /path/to/nixpkgs])
~~~

## Faster invocation of EMACS with pretty customizations (this assumes image already loaded)
~~~
MODE=development $(nix-build -A emacs.run [--argstr pkgsPath /path/to/nixpkgs])
~~~

## Using as an overlay
If you're using NixOS or Nix package manager, you can use this
repository's overlays directory and get advantage of nix overlays.


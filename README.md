# Kitsilano
Portable Development Environment for myself

## Using prebuilt docker images
To build docker image and load it:
~~~
docker load < $(nix-build -A images --argstr pkgsPath /home/fxr/nixpkgs)
~~~

To execute emacs environment:
~~~
docker run -it --rm -v $PWD:/data emacs:latest
~~~

## Using as an overlay
If you're using NixOS or Nix package manager, you can use this
repository's overlays directory and get advantage of nix overlays.

## Contributing

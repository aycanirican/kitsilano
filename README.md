# Kitsilano
Portable Development Environment for myself

## For practical users

### Run Kits in NixOS
~~~
$(nix-build -A emacs.run) -nw # -nw and rest of the args will be passed to emacs
~~~

### Run Kits in a container
~~~
$(nix-build -A emacs.run --argstr withContainer true [--argstr pkgsPath ~/nixpkgs])
~~~

### Run prebuilt container image (skip loading generated image)
~~~
MODE=development $(nix-build -A emacs.run [--argstr pkgsPath /path/to/nixpkgs])
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

{ pkgs }:

with pkgs;

let
  version = "latest";
  
  baseImage = dockerTools.buildLayeredImage {
    name = "baseImage";
    tag = version;
    contents = [ bash glibcLocales cacert coreutils curl git ];
  };
  
  myEmacs = pkgs.emacs27Env ((import ../conf/emacs.nix) pkgs);
  
  commonImage = name: entrypoint: paths: dockerTools.buildImage {
    inherit name;
    diskSize  = 6000;
    tag       = version;
    fromImage = baseImage;
    runAsRoot = ''
      ${dockerTools.shadowSetup}
      mkdir -p $out/etc/pam.d
      echo "root:x:0:0::/root:/bin/sh" > $out/etc/passwd
      echo "user:x:1000:1000::/home/user:" >> $out/etc/passwd
      echo "root:!x:::::::" > $out/etc/shadow
      echo "user:!:::::::" >> $out/etc/shadow
      echo "root:x:0:" > $out/etc/group
      echo "users:x:1000:" >> $out/etc/group
      echo "root:x::" > $out/etc/gshadow
      echo "users:!::" >> $out/etc/gshadow

      mkdir /tmp && chmod 1777 /tmp
      groupadd -g 100 -r users && useradd -u 1001 --no-log-init -g users -m user
      mkdir -p /home/user/data
      mkdir -p /home/user/.emacs.d/
      chown -R user:users /home/user

      echo "tcp	6	TCP\nudp 17      UDP" >> /etc/protocol
      echo "hosts: files dns myhostname mymachines" > /etc/nsswitch.conf
    '';
    config = {
      Cmd = [ "${gosu}/bin/gosu" "user" "/bin/sh" "-c" "${entrypoint}" ];
      Env = [ "LANG=en_US.UTF-8"
              "LOCALE_ARCHIVE=${glibcLocales}/lib/locale/locale-archive"
              "PATH=${paths}:$PATH"
            ];
      WorkingDir = "/home/user/data";
      Volumes = { };
    };
  };

  publish = { name, image, constants }: pkgs.writeScript "${name}-publish" ''
    set -Eeo pipefail
    DCKR="${pkgs.docker}/bin/docker"
    PACKAGE="${name}"
    VERSION="$1"

    if [[ -z "$VERSION" ]]; then
      echo "Usage: $0 <version>"
      exit 1
    fi

    echo "Building docker image for $PACKAGE"
    docker load < ${image}
    IMAGE_ID=$(docker image ls $PACKAGE:latest --format '{{.ID}}')
    echo "Loaded image id : $IMAGE_ID"

    $DCKR tag $IMAGE_ID ${constants.dockerAccount}/$PACKAGE:$VERSION
    $DCKR tag $IMAGE_ID ${constants.dockerAccount}/$PACKAGE:latest
    $DCKR push          ${constants.dockerAccount}/$PACKAGE

    echo "Released new version of $PACKAGE-$VERSION"
    echo "Run it: docker run -it --rm ${constants.dockerAccount}/$PACKAGE:$VERSION"
  '';

in {
  inherit publish;
  
  ihaskell  = { entrypoint, paths }: commonImage "ihaskell" entrypoint paths;
  haskell   = { entrypoint, paths }: commonImage "haskell"  entrypoint paths;
  emacs     = { entrypoint, paths }: commonImage "emacs"    entrypoint paths;
  selenium  = { entrypoint, paths }: commonImage "selenium" entrypoint paths;
  acme = { entrypoint, paths }: commonImage "acme" entrypoint paths;
}

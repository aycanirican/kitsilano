{ pkgs, myEmacs }:

with pkgs;

let
  version = "0.3";
  baseImage = dockerTools.buildLayeredImage {
    name = "baseImage";
    tag = version;
    contents = [ bashInteractive cacert busybox curl git ];
    # maxLayers = 120;
  };

in
{ emacsImage = dockerTools.buildImage {
    name = "emacs";
    tag  = version;
    fromImage = baseImage;
    contents = [ myEmacs mu isync gnupg ];
    runAsRoot = ''
      ${dockerTools.shadowSetup}
      echo "tcp	6	TCP\nudp 17      UDP" >> /etc/protocol
      echo "hosts: files dns myhostname mymachines" > /etc/nsswitch.conf
      groupadd -g 100 -r users && useradd -u 1000 --no-log-init -d /data -r -g users user
      mkdir -p /data
      chown user:users /data
    '';
    config = {
      Cmd = [ "${pkgs.gosu.bin}/bin/gosu" "user" "emacs" ];
      WorkingDir = "/data";
      Volumes = { };
    };
  };
}

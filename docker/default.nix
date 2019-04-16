{ pkgs, emacsEnv }:

let
  version = "0.4";
  baseImage = pkgs.dockerTools.buildLayeredImage {
    name = "baseImage";
    tag = version;
    contents = with pkgs; [ bashInteractive cacert busybox curl git ];
    maxLayers = 120;
  };

in
{ emacsImage = pkgs.dockerTools.buildImage {
    name = "emacs";
    tag  = version;
    fromImage = baseImage;
    contents = with pkgs; [ emacsEnv mu isync gnupg ];
    runAsRoot = ''
      ${pkgs.dockerTools.shadowSetup}
      echo "tcp	6	TCP\nudp 17      UDP" >> /etc/protocol
      echo "hosts: files dns myhostname mymachines" > /etc/nsswitch.conf
      mkdir /tmp && chmod 1777 /tmp
      mkdir -p /home/user/data
      groupadd -g 100 -r users && useradd -u 1001 --no-log-init -g users -m user
      chown -R user:users /home/user
    '';
    config = {
      Cmd = [ "${pkgs.gosu.bin}/bin/gosu" "user" "${emacsEnv}/bin/emacs" ];
      WorkingDir = "/home/user/data";
      Volumes = { };
    };
  };
}

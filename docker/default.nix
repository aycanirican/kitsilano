{ pkgs, emacsEnv }:
with pkgs;

let
  version = "latest";
  baseImage = dockerTools.buildImage {
    name = "baseImage";
    tag = version;
    contents = [ bashInteractive glibcLocales cacert busybox curl git ];
    # maxLayers = 120;
  };

in
{ emacsImage = dockerTools.buildImage {
    name = "emacs";
    tag  = version;
    fromImage = baseImage;
    contents = [ emacsEnv mu isync gnupg silver-searcher ];
    runAsRoot = ''
      ${dockerTools.shadowSetup}
      echo "tcp	6	TCP\nudp 17      UDP" >> /etc/protocol
      echo "hosts: files dns myhostname mymachines" > /etc/nsswitch.conf
      mkdir /tmp && chmod 1777 /tmp
      mkdir -p /home/user/data
      groupadd -g 100 -r users && useradd -u 1001 --no-log-init -g users -m user
      chown -R user:users /home/user
    '';
    config = {
      Cmd = [ "${gosu.bin}/bin/gosu" "user" "${emacsEnv}/bin/emacs" ];
      Env = [ "LANG=en_US.UTF-8"
              "LOCALE_ARCHIVE=${glibcLocales}/lib/locale/locale-archive" ];
      WorkingDir = "/home/user/data";
      Volumes = { };
    };
  };
}

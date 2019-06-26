{ pkgs }:

with pkgs;

let
  version = "latest";
  
  baseImage = dockerTools.buildImage {
    name = "baseImage";
    tag = version;
    contents = [ bashInteractive glibcLocales cacert coreutils curl git ];
  };
  
  myEmacs = pkgs.emacs26Env ((import ../conf/emacs.nix) pkgs);
  
  commonImage = name: run: dockerTools.buildImage {
    diskSize = 8192;
    inherit name;
    tag  = version;
    fromImage = baseImage;
    runAsRoot = ''
      ${dockerTools.shadowSetup}
      echo "tcp	6	TCP\nudp 17      UDP" >> /etc/protocol
      echo "hosts: files dns myhostname mymachines" > /etc/nsswitch.conf
      mkdir /tmp && chmod 1777 /tmp
      mkdir -p /home/user/data
      mkdir -p /home/user/.emacs.d/
      groupadd -g 100 -r users && useradd -u 1001 --no-log-init -g users -m user
      chown -R user:users /home/user
    '';
    config = {
      Cmd = [ "${gosu.bin}/bin/gosu" "user" "/bin/sh" "-c" "${run}" ];
      Env = [ "LANG=en_US.UTF-8"
              "LOCALE_ARCHIVE=${glibcLocales}/lib/locale/locale-archive" ];
      WorkingDir = "/home/user/data";
      Volumes = { };
    };
  };

in {
  haskell  = run: commonImage "haskell"   run;
  emacs    = run: commonImage "kitsilano" run;
  selenium = run: commonImage "selenium"  run;
}

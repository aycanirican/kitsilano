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
      mkdir -p /home/user/data
      mkdir -p /home/user/.emacs.d/
      groupadd -g 100 -r users && useradd -u 1001 --no-log-init -g users -m user
      chown -R user:users /home/user

      echo "tcp	6	TCP\nudp 17      UDP" >> /etc/protocol
      echo "hosts: files dns myhostname mymachines" > /etc/nsswitch.conf
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
  ihaskell  = run: commonImage "ihaskell"  run;
  haskell   = run: commonImage "haskell"   run;
  emacs     = run: commonImage "kitsilano" run;
  selenium  = run: commonImage "selenium"  run;
}

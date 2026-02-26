{ lib, pkgs, ... }:

let
  # SSH uses x11-ssh-askpass program for asking for passphrase,
  # and it is set via SSH_ASKPASS variable. However, this is
  # GUI-based, so if we want TTY, we have to create a pinentry
  # wrapper that will work with SSH.
  # https://bbs.archlinux.org/viewtopic.php?id=57500
  askpass = pkgs.writeShellScriptBin "askpass" ''
    #!/usr/bin/env bash

    RESULT=$(pinentry-curses --ttytype=xterm-color --lc-ctype=en_AU.UTF8 --ttyname=/dev/tty <<END | egrep '^(D|ERR)'
    SETDESC Enter your SSH password:
    SETPROMPT
    GETPIN
    END)

    if [ "$RESULT" == "ERR 111 canceled" ]; then
        exit 255
    else
        echo ''${RESULT:2:''${#RESULT}-2}
    fi

    RESULT=

    # required otherwise text becomes garbled
    stty sane
    # reset
  '';
in {
  programs.ssh.askPassword = lib.mkForce "${askpass}/bin/askpass";
  environment.systemPackages = [ pkgs.pinentry-curses ];
}

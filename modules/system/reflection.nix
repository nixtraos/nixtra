# reflection.nix
#
# "Metaconfiguration" that gets added by Nixtra code itself
# to your configuration. This is mostly used for hacky/temporary
# fixes, such as for fixing the environment variable used by SSH
# for askpass.
# It's called reflection because Nixtra code can essentially reflect
# on itself and use its own interface that it provides to the user to
# make its own work easier; a metaphor to real reflection systems
# in programming languages.
# This is needed because any Nixtra configuration set by an import of
# configuration.nix will be overwritten by the user configuration.
#
# Reflection happens after the following processes finish:
# preset integration, profile integration

{ pkgs, nixtra, ... }:

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
  user.shell.environmentVariables = if nixtra.ssh.enable then {
    SSH_ASKPASS = "${askpass}/bin/askpass";
  } else
    { };
}

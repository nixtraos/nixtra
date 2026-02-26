# https://www.reddit.com/r/NixOS/comments/1onioq2/nixos_security_tip_part_2_remove_unnecessary_suid

{ lib, ... }:

{
  #security.enableWrappers = false;

  security.wrappers = {
    #su.setuid = lib.mkForce true;
    #sudo.setuid = lib.mkForce true;
    doas.setuid = lib.mkForce true;
    pkexec.setuid = lib.mkForce true; # required for polkit stuff

    #sudoedit.setuid = lib.mkForce false;
    fusermount.setuid = lib.mkForce false;
    fusermount3.setuid = lib.mkForce false;
    mount.setuid = lib.mkForce false;
    umount.setuid = lib.mkForce false;
    sg.setuid = lib.mkForce false;
    newgrp.setuid = lib.mkForce false;
    newgidmap.setuid = lib.mkForce false;
    newuidmap.setuid = lib.mkForce false;
  };
}

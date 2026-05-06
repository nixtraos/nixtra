{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    tree
    killall
    file
    lsof
    reuse
  ];
}

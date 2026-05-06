{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    session-desktop
    dissent
  ];
}

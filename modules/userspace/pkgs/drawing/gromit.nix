{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    gromit-mpx # Drawing on the screen
  ];
}

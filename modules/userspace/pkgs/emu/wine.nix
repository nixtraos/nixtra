{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    #wineWowPackages.waylandFull
    #wineWowPackages.stagingFull
    #winetricks
  ];
}

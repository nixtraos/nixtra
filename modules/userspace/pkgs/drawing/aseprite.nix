{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    aseprite # Pixel art
  ];
}

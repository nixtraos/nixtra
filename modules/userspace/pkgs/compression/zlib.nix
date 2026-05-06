{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    p7zip
    zlib
    zlib-ng
  ];
}

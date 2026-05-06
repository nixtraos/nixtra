{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    binwalk # Extract hard-coded embedded source files from binaries
  ];
}

{ config, pkgs, ... }:

{
  home.packages = with pkgs;
    [
      gamescope
      #qt6.full
    ];
}

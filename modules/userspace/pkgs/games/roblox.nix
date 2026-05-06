{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    #sober
    vinegar
  ];
}

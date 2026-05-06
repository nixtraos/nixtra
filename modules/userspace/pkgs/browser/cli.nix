{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    w3m
    links2
    elinks
  ];
}

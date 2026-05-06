{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    #jdk8
    #jdk17
    #jdk21
    #openjdk17
    #openjdk21
    gradle
  ];
}

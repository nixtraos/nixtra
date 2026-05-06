{ pkgs, ... }:

{
  # home.packages =
  #   [ inputs.wayscriber.packages.${profileSettings.arch}.default ];
  home.packages = [ pkgs.wayscriber ];
}

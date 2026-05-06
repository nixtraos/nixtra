{ config, pkgs, ... }:

{
  programs.swayimg.settings = {
    viewer = {
      transparency = "#00000000";
    };

    "keys.viewer" = {
      "Shift+r" = "rand_file";
    };
  };
}

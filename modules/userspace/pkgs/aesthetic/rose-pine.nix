{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    rose-pine-cursor
    rose-pine-hyprcursor
  ];

  gtk.cursorTheme = {
    name = "rose-pine";
    package = pkgs.rose-pine-cursor;
    size = 24;
  };
}

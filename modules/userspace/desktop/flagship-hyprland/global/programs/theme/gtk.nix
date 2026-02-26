{ config, lib, pkgs, ... }:

{
  config = lib.mkIf (config.nixtra.user.desktop == "flagship-hyprland") {
    gtk = {
      enable = true;

      # TODO: fix removed package from repo
      #iconTheme = {
      #  name = "TokyoNight-SE";
      #  package = pkgs.tokyo-night-icons;
      #};
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
        #name = "Tokyonight-Dark";
      };

      theme = {
        name = "Tokyonight-Dark";
        #name = "Tokyonight-Dark-BL";
        package = pkgs.tokyonight-gtk-theme;
      };

      cursorTheme = {
        name = "BreezeX-RosePine-Linux";
        package = pkgs.rose-pine-cursor;
        size = 24;
      };
    };

    home.pointerCursor = {
      name = "BreezeX-RosePine-Linux";
      package = pkgs.rose-pine-cursor;
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        cursor-theme = "BreezeX-RosePine-Linux";
        cursor-size = 24;
      };
    };

    # https://discourse.nixos.org/t/setting-nautiilus-gtk-theme/38958/7
    xdg.configFile = {
      "gtk-3.0" = {
        source =
          "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-3.0";
        recursive = true;
      };
      "gtk-4.0" = {
        source =
          "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0";
        recursive = true;
      };
    };

    # if above doesnt work, try this
    # NOTE: GTK_THEME is a debugging variable
    #home.sessionVariables = {
    #  GTK_THEME = config.gtk.theme.name;
    #  XCURSOR_THEME
    #};
  };
}

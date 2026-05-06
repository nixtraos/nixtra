{ lib, config, ... }:

{
  config = lib.mkIf (config.nixtra.display.themeType != "") {
    dconf = {
      enable = true;
      settings = {
        "org/gnome/desktop/interface" =
          if config.nixtra.display.themeType == "dark" then
            {
              color-scheme = "prefer-dark";
              gtk-application-prefer-dark-theme = true;
            }
          else
            { };
      };
    };
  };
}

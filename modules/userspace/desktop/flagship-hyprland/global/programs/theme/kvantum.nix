{
  pkgs,
  config,
  lib,
  ...
}:

{
  config = lib.mkIf (config.nixtra.user.desktop == "flagship-hyprland") {
    home.packages = [
      (pkgs.catppuccin-kvantum.override {
        accent = "blue";
        variant = "macchiato";
      })
    ];

    xdg.configFile = {
      "Kvantum/Catppuccin-Macchiato-Blue/Catppuccin-Macchiato-Blue/Catppuccin-Macchiato-Blue.kvconfig".source =
        "${pkgs.catppuccin-kvantum}/share/Kvantum/Catppuccin-Macchiato-Blue/Cattpuccin-Macchiato-Blue.kvconfig";
      "Kvantum/Catppuccin-Macchiato-Blue/Catppuccin-Macchiato-Blue/Catppuccin-Macchiato-Blue.svg".source =
        "${pkgs.catppuccin-kvantum}/share/Kvantum/Catppuccin-Macchiato-Blue/Cattpuccin-Macchiato-Blue.svg";
      "Kvantum/kvantum.kvconfig".source = pkgs.formats.ini.generate "kvantum.kvconfig" {
        General.theme = "Catppuccin-Macchiato-Blue";
      };
    };
  };
}

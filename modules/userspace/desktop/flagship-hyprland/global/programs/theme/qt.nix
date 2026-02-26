# https://discourse.nixos.org/t/guide-to-installing-qt-theme/35523/3

{ config, lib, pkgs, ... }:

let cfg = config.nixtra.desktop.theme.qt;
in {
  config = lib.mkIf (config.nixtra.user.desktop == "flagship-hyprland") {
    qt = {
      enable = true;

      platformTheme.name = "qtct";
      style.name = "kvantum";
    };

    xdg.configFile = {
      "Kvantum/kvantum.kvconfig".text = ''
        [General]
        theme=${cfg.selection}
      '';
    };

    home.file.".config/Kvantum" = {
      source = "${cfg.package}/share/Kvantum";
      recursive = true;
    };

    home.sessionVariables = {
      QT_QPA_PLATFORMTHEME = "qt5ct";
      QT_STYLE_OVERRIDE = "kvantum";
    };
  };
}

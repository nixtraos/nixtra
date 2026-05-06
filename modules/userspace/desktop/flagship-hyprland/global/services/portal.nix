{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf (config.nixtra.user.desktop == "flagship-hyprland") {
    xdg.portal.enable = true;
    xdg.portal.extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland

      kdePackages.xdg-desktop-portal-kde
      xdg-desktop-portal-gtk
    ];
  };
}

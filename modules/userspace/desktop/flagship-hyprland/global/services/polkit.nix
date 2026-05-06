{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf (config.nixtra.user.desktop == "flagship-hyprland") {
    home.packages = with pkgs; [ hyprpolkitagent ];

    services.hyprpolkitagent.enable = true;
    #services.blueman-applet.enable = true; # often used with bluetooth
    #services.polkit-gnome.enable = true;
  };
}

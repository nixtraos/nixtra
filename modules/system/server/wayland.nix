{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf (config.nixtra.display.enable && config.nixtra.display.server == "wayland") {
    # Enable display manager
    services.xserver.enable = true;
    services.displayManager = {
      enable = true;
      sddm.wayland.enable = true;
    };

    environment.systemPackages = with pkgs; [
      wayland
      wayland-protocols
      wayland-utils # Commands like wayland-info
      plymouth # Display manager dependency
      xorg.libX11 # Optional, for XWayland fallback
      xorg.libxcb # Optional

      # Utils
      swayimg # Display images
      clipman # Copy text to clipboard
      cliphist # View clipboard history
      wl-clipboard # Watch event for clipboard
    ];

    environment.sessionVariables = {
      # Hint electron apps to use Wayland
      NIXOS_OZONE_WL = "1";

      # https://stackoverflow.com/a/71402854
      QT_QPA_PLATFORM = "wayland";

      # https://askubuntu.com/a/1044432
      #QT_QPA_PLATFORMTHEME = "gtk3";
    };

    systemd.services.restart-display-manager = {
      enable = true;

      script = ''
        if ! systemctl is-active --quiet display-manager; then
            echo "Display manager is not running. Restarting..."
            systemctl restart display-manager
        fi
      '';

      description = "Restart Display Manager if not running";
      after = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
      };
    };
  };
}

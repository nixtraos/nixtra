{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf (config.nixtra.user.desktop == "flagship-hyprland") {
    services.mako = {
      enable = true;
      settings = {
        anchor = "top-right";
        sort = "-time";
        layer = "overlay";
        #background-color = "#00000000";
        background-color = "#2E344080";
        width = 300;
        height = 110;
        border-size = 2;
        border-color = "#ffffff";
        border-radius = 15;
        icons = true;
        max-icon-size = 64;
        default-timeout = 5000;
        ignore-timeout = 1;
        font = "monospace 14";

        # Play sound effect for notifications
        on-notify = "exec vlc --gain 0.5 --vout none --intf dummy ${../../../../assets/audio/notification.mp3}";

        "urgency=low" = {
          border-color = "#cccccc";
        };

        "urgency=normal" = {
          border-color = "#d08770";
        };

        "urgency=high" = {
          border-color = "#bf616a";
          default-timeout = 0;
        };

        "category=mpd" = {
          default-timeout = 3000;
          group-by = "category";
        };
      };
    };
  };
}

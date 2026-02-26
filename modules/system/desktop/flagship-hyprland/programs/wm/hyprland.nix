{ nixtraLib, config, lib, pkgs, ... }:

{
  config = lib.mkIf (config.nixtra.user.desktop == "flagship-hyprland") {
    # Enable compositor
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
      systemd.setPath.enable = true;
    };
    programs.dconf.enable = true;

    environment.systemPackages = with pkgs; [
      hyprland-qtutils # Dependency for some Hyprland dialogs
      waybar # Wayland bar
      mako # Notif manager
      swww # Wallpaper daemon
      rofi # App launcher
      plymouth # Display manager dependency
      gsettings-desktop-schemas # GSettings Schemas (directory popups)
      adwaita-icon-theme
      gtk3
      tzdata
      hyprpicker

      # Dependencies by cava module in waybar
      iniparser
      fftw
      helvum
      libnotify

      # Misc dependencies
      lm_sensors

      vlc # Startup sound effect
      gromit-mpx # Drawing

      # Hypr ecosystem
      hyprshade
      hyprsunset
      hyprlock

      # Wayland programs
      swayidle
    ];

    environment.sessionVariables = {
      HYPR_PLUGIN_DIR = pkgs.symlinkJoin {
        name = "hyprland-plugins";
        paths = with pkgs.hyprlandPlugins; [
          hyprspace
          hyprtrails
          hypr-dynamic-cursors
          hyprfocus
          #hyprexpo
        ];
      };

      # Make Git not try to open an authorization window for pushing
      # and other operations, fixes a crash for Hyprland.
      GIT_ASKPASS = "/bin/stub";
    };

    # Create a named pipe (FIFO) at boot time
    systemd.services.create-hypr-pipe = {
      description = "Create named pipe for Hyprland";
      wantedBy = [ "multi-user.target" ];

      script = ''
        #!/bin/sh
        rm -f /tmp/hypr_start_pipe
        mkfifo /tmp/hypr_start_pipe
        chmod 666 /tmp/hypr_start_pipe
      '';

      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
    };
  };
}

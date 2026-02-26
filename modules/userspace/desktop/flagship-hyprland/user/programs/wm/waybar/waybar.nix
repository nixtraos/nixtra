{ config, nixtraLib, lib, pkgs, ... }:

let
  # Function to generate Waybar custom modules
  mkAppModule = app:
    let
      program =
        builtins.unsafeDiscardStringContext (builtins.baseNameOf app.program);
    in {
      name = "custom/${program}";
      value = {
        format = "    ";
        on-click = "/home/user/.nix-profile/bin/${program}";
        tooltip = false;
        class = "app-icon";
      };
    };

  iconSize = builtins.toString config.nixtra.desktop.taskbar.iconSize;
  scaledSize = builtins.toString (config.nixtra.desktop.taskbar.iconSize
    + config.nixtra.desktop.taskbar.iconSize * 0.1);

  mkCssRule = app:
    let
      program =
        builtins.unsafeDiscardStringContext (builtins.baseNameOf app.program);
    in ''
      #custom-${program} {
        background-image: url('/home/${config.nixtra.user.username}/.config/waybar/icons/${app.icon}');
        background-position: center;
        background-repeat: no-repeat;
        background-size: ${iconSize}px ${iconSize}px;
        min-width: ${iconSize}px;
        min-height: ${iconSize}px;
        transition: min-width 0.1s ease-in-out, min-height 0.1s ease-in-out;
      }

      #custom-${program}:hover {
        min-width: ${scaledSize}px;
        min-height: ${scaledSize}px;
      }
    '';

  # Nixtra's logo
  nixtraCssRule = ''
    #custom-nixtra {
      background-image: url('/home/${config.nixtra.user.username}/.config/waybar/icons/nixtra.png');
      background-position: center;
      background-repeat: no-repeat;
      background-size: 32px 32px;
      min-width: 32px;
      min-height: 32px;
      margin-left: 15px;
    }
  '';

  hoverActiveCss = ''
    .app-icon:hover {
    }

    .app-icon:active {
        animation: active-animation 0.1s ease forwards;
    }
  '';

  apps = (config.nixtra.desktop.taskbar.apps);

  # Generate all custom modules
  customModules = builtins.listToAttrs (map mkAppModule apps);
  customCssRules = builtins.concatStringsSep "\n" (map mkCssRule apps);
  cssRules = hoverActiveCss + "\n" + customCssRules + "\n" + nixtraCssRule;

  # Generate the modules-center array
  appModules = map (app:
    let
      program =
        builtins.unsafeDiscardStringContext (builtins.baseNameOf app.program);
    in "custom/${program}") apps;

  script-ram-graph = pkgs.callPackage ./scripts/ram-graph.nix {
    inherit (nixtraLib.command) createCommand;
  };
  script-cpu-graph = "${./scripts/ram_graph.py}";
in {
  config = lib.mkIf (config.nixtra.user.desktop == "flagship-hyprland") {
    programs.waybar = {
      settings = {
        "config-top" = {

          reload_style_on_change = true;
          layer = "top";
          position = "top";
          "disable-scroll" = true;
          mode = "dock";

          "modules-left" = [
            "network"
            #"custom/ram-graph"
            #"custom/cpu-graph"
            "cava"
            "custom/netspeed"
          ];

          "modules-center" =
            [ "custom/separator" "hyprland/workspaces" "custom/separator" ];

          "modules-right" = [
            "custom/record"
            "custom/screenshot"
            "custom/separator"
            "wireplumber"
            "temperature"
            "battery"
            "cpu"
            "custom/gpu"
            "clock"
            "custom/separator"
            "custom/suspend"
            "custom/reboot"
            "custom/shutoff"
          ];

          "hyprland/workspaces" = {
            format = "{icon}";
            format-icons = lib.mkMerge ((lib.imap1
              (i: workspace: { "${builtins.toString i}" = workspace.icon; })
              config.nixtra.desktop.flagship-hyprland.workspaces) ++ [{
                active = "";
                default = "";
              }]);
            "active-only" = false;
          };

          network = {
            #format = " {ifname}: {ipaddr}";
            #format-disconnected = " {ifname}: Disconnected";
            format = "";
            format-disconnected = "";
            tooltip = true;
          };

          cava = {
            framerate = 60;
            sensitivity = 1;
            #bars = 22;
            bars = 16;
            lower_cutoff_freq = 2000;
            higher_cutoff_freq = 3000;
            method = "pipewire";
            source = "auto";
            stereo = true;
            reverse = false;
            bar_delimiter = 0;
            monstercat = false;
            waves = false;
            noise_reduction = 0.77;
            input_delay = 4;
            format-icons = [ "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█" ];
            actions = { on-click-right = "mode"; };
            sleep_timer = 2;
          };

          # CPU graph
          "custom/cpu-graph" = {
            exec = "${script-cpu-graph} -d 16";
            format = "<span color='#FFA500'>  </span>{}";
            interval = 1;
            return-type = "json";
            on-click = "${script-cpu-graph} toggle";
          };

          # RAM graph
          "custom/ram-graph" = {
            exec = "${script-ram-graph}/bin/ram-graph";
            return-type = "json";
            interval = 1;
            format = "{}";
            format-icons = [ "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█" ];
            tooltip = true;
          };

          # Quick links
          "custom/browser" = {
            format = "  ";
            on-click = "${config.home.profileDirectory}/bin/librewolf";
            tooltip = false;
            interval = "once";
          };
          "custom/terminal" = {
            format = " ";
            on-click = "${config.home.profileDirectory}/bin/kitty";
            tooltip = false;
            interval = "once";
          };
          "custom/explorer" = {
            format = "  ";
            on-click = "${config.home.profileDirectory}/bin/pcmanfm";
            tooltip = false;
            interval = "once";
          };

          "custom/screenshot" = {
            name = "cwidget";
            format = "   ";
            on-click = "/run/current-system/sw/bin/nixtra-screenshot";
            on-click-right =
              "/run/current-system/sw/bin/nixtra-screenshot region";
            tooltip = false;
            interval = "once";
          };

          "custom/record" = {
            name = "cwidget";
            exec = "/run/current-system/sw/bin/nixtra-record status";
            format = " {}";
            on-click =
              "/run/current-system/sw/bin/nixtra-record toggle fullscreen";
            on-click-right =
              "/run/current-system/sw/bin/nixtra-record toggle region";
            restart-interval = 1;
            return-type = "json";
            tooltip = true;
          };

          "custom/github" = {
            format = "  ";
            on-click =
              "${config.home.profileDirectory}/bin/librewolf https://github.com";
            tooltip = false;
            interval = "once";
          };

          "custom/colour-temperature" = {
            format = "{} ";
            exec = "wl-gammarelay-rs watch {t}";
            on-scroll-up =
              "busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n +100";
            on-scroll-down =
              "busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n -100";
          };

          #"custom/gpu" = {
          #  exec = "${../../../scripts/gpuinfo.sh}";
          #  return-type = "json";
          #  format = " {}";
          #  interval = 5;
          #  tooltip = true;
          #  max-length = 1000;
          #};

          "custom/netspeed" = {
            name = "net_speed";
            exec = "${./scripts/net_speed.sh}";
            interval = 1;
            return-type = "json";
          };

          # System Info
          cpu = {
            name = "cwidget";
            interval = 10;
            format = " {}%";
            "max-length" = 10;
          };

          wireplumber = {
            name = "cwidget";
            format = "{volume}% {icon}";
            format-muted = "";
            on-click = "helvum";
            format-icons = [ "" "" "" ];
          };

          temperature = {
            name = "cwidget";
            #format = "{temperatureC}°C ";
            hwmon-path = "/sys/class/hwmon/hwmon1/temp1_input";
            critical-threshold = 83;
            format = "{icon} {temperatureC}°C";
            format-icons = [ "" "" "" ];
            interval = 10;
          };

          #"hyprland/language" = {
          #  format = "{short}"; # can use {short} and {variant}
          #  on-click = "${../../../scripts/keyboardswitch.sh}";
          #};

          clock = { format = " {:%H:%M}"; };

          # Power buttons
          "custom/suspend" = {
            name = "cwidget";
            format = "  ";
            on-click = "systemctl suspend";
            tooltip = false;
            interval = "once";
          };

          "custom/reboot" = {
            name = "cwidget";
            format = " ";
            on-click = "reboot";
            tooltip = false;
            interval = "once";
          };

          "custom/shutoff" = {
            name = "cwidget";
            format = " ";
            on-click = "shutdown now";
            tooltip = false;
            interval = "once";
          };

          tray = {
            "icon-size" = 21;
            spacing = 100;
          };

          "custom/separator" = {
            format = "│";
            tooltip = false;
          };

          "custom/spacer" = {
            format = " ";
            tooltip = false;
          };

        };

        "config-bottom" = {
          reload_style_on_change = true;
          layer = "bottom";
          position = "bottom";
          disable-scroll = true;
          modules-center = appModules;
          modules-left = [ "custom/nixtra" ];

          "custom/nixtra" = {
            format = "    ";
            on-click =
              "${config.nixtra.user.browser} https://github.com/quarterstar/nixtra";
            tooltip = false;
          };
        } // customModules;
      };
    };

    xdg.configFile."waybar/config-top".text =
      builtins.toJSON config.programs.waybar.settings."config-top";
    xdg.configFile."waybar/config-top.css".text = ''
      @define-color base   #1e1e2e;
      @define-color mantle #181825;
      @define-color crust  #11111b;

      @define-color text     #cdd6f4;
      @define-color subtext0 #a6adc8;
      @define-color subtext1 #bac2de;

      @define-color surface0 #313244;
      @define-color surface1 #45475a;
      @define-color surface2 #585b70;

      @define-color overlay0 #6c7086;
      @define-color overlay1 #7f849c;
      @define-color overlay2 #9399b2;

      @define-color blue      #89b4fa;
      @define-color lavender  #b4befe;
      @define-color sapphire  #74c7ec;
      @define-color sky       #89dceb;
      @define-color teal      #94e2d5;
      @define-color green     #a6e3a1;
      @define-color yellow    #f9e2af;
      @define-color peach     #fab387;
      @define-color maroon    #eba0ac;
      @define-color red       #f38ba8;
      @define-color mauve     #cba6f7;
      @define-color pink      #f5c2e7;
      @define-color flamingo  #f2cdcd;
      @define-color rosewater #f5e0dc;

      * {
          /* `otf-font-awesome` is required to be installed for icons */
          /* font-family: FontAwesome, Roboto, Helvetica, Arial, sans-serif; */
          font-family: "Roboto", "Font Awesome 5 Free";
          font-size: 25px;
          transition: font-size 0.1s ease-out;
      }

      .cwidget:hover {
          font-size: 27px;
      }

      window#waybar {
          background-color: rgba(43, 48, 59, 0.5);
          border-bottom: 3px solid rgba(100, 114, 125, 0.5);
          color: #ffffff;
          transition-property: background-color;
          transition-duration: .5s;
      }

      window#waybar.hidden {
          opacity: 0.2;
      }

      /*
      window#waybar.empty {
          background-color: transparent;
      }
      window#waybar.solo {
          background-color: #FFFFFF;
      }
      */

      window#waybar.termite {
          background-color: #3F3F3F;
      }

      window#waybar.chromium {
          background-color: #000000;
          border: none;
      }


      tooltip {
          background: #1e1e2e;
          border-radius: 8px;
      }

      tooltip label {
          color: #cad3f5;
          margin-right: 5px;
          margin-left: 5px;
      }

      button {
          /* Use box-shadow instead of border so the text isn't offset */
          box-shadow: inset 0 -3px transparent;
          /* Avoid rounded borders under each button name */
          border: none;
          border-radius: 0;
      }

      /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
      button:hover {
          background: inherit;
          box-shadow: inset 0 -3px #ffffff;
      }

      /* you can set a style on hover for any module like this */
      #pulseaudio:hover {
          background-color: #a37800;
      }

      #workspaces {
          padding: 15px;
      }

      #workspaces button {
          background-color: transparent;
          color: #ffffff;
      }

      #workspaces button:hover {
          background: rgba(0, 0, 0, 0.2);
      }

      #workspaces button.focused {
          background-color: #64727D;
          box-shadow: inset 0 -3px #ffffff;
      }

      #workspaces button.urgent {
          background-color: #eb4d4b;
      }

      #mode {
          background-color: #64727D;
          box-shadow: inset 0 -3px #ffffff;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #disk,
      #temperature,
      #backlight,
      #network,
      #pulseaudio,
      #wireplumber,
      #custom-media,
      #tray,
      #mode,
      #idle_inhibitor,
      #scratchpad,
      #power-profiles-daemon,
      #mpd,
      #custom-netspeed {
          padding: 0 10px;
          color: #ffffff;
      }

      #custom-ram-graph {
          padding: 0 5px;
          margin: 2px 5px;
      }

      #window,
      #workspaces {
          margin: 0 4px;
      }

      /* If workspaces is the leftmost module, omit left margin */
      .modules-left>widget:first-child>#workspaces {
          margin-left: 0;
      }

      /* If workspaces is the rightmost module, omit right margin */
      .modules-right>widget:last-child>#workspaces {
          margin-right: 0;
          transition: 0.2s ease-out;
      }

      #clock {
          /* background-color: #64727D; */
          background-color: transparent;
      }

      #battery {
          background-color: transparent;
          color: #000000;
      }

      #battery.charging,
      #battery.plugged {
          color: #ffffff;
          background-color: #26A65B;
      }

      @keyframes blink {
          to {
              background-color: #ffffff;
              color: #000000;
          }
      }

      /* Using steps() instead of linear as a timing function to limit cpu usage */
      #battery.critical:not(.charging) {
          background-color: #f53c3c;
          color: #ffffff;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: steps(12);
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }

      #power-profiles-daemon {
          padding-right: 15px;
      }

      #power-profiles-daemon.performance {
          background-color: #f53c3c;
          color: #ffffff;
      }

      #power-profiles-daemon.balanced {
          background-color: #2980b9;
          color: #ffffff;
      }

      #power-profiles-daemon.power-saver {
          background-color: #2ecc71;
          color: #000000;
      }

      label:focus {
          background-color: #000000;
      }

      #cpu {
          /* background-color: #2ecc71; */
          background-color: transparent;
          color: #000000;
          color: white;
      }

      #memory {
          background-color: #9b59b6;
      }

      #disk {
          background-color: #964B00;
      }

      #backlight {
          background-color: #90b1b1;
      }

      #network {
          color: lightgreen;
      }

      #network.disconnected {
          /* background-color: #f53c3c; */
          color: red;
      }

      #pulseaudio {
          background-color: #f1c40f;
          color: #000000;
      }

      #pulseaudio.muted {
          background-color: #90b1b1;
          color: #2a5c45;
      }

      #wireplumber {
          /* background-color: #fff0f5; */
          background-color: transparent;
      }

      #custom-media {
          background-color: #66cc99;
          color: #2a5c45;
          min-width: 100px;
      }

      #custom-media.custom-spotify {
          background-color: #66cc99;
      }

      #custom-media.custom-vlc {
          background-color: #ffa000;
      }

      #custom-spacer {
          min-width: 20px;
          /* Adjust this value to control the spacing */
      }

      #temperature {
          background-color: transparent;
      }

      #temperature.critical {
          color: #eb4d4b;
      }

      #tray {
          background-color: #2980b9;
      }

      #tray>.passive {
          -gtk-icon-effect: dim;
      }

      #tray>.needs-attention {
          -gtk-icon-effect: highlight;
          background-color: #eb4d4b;
      }

      #idle_inhibitor {
          background-color: #2d3436;
      }

      #idle_inhibitor.activated {
          background-color: #ecf0f1;
          color: #2d3436;
      }

      #mpd {
          background-color: #66cc99;
          color: #2a5c45;
      }

      #mpd.disconnected {
          background-color: #f53c3c;
      }

      #mpd.stopped {
          background-color: #90b1b1;
      }

      #mpd.paused {
          background-color: #51a37a;
      }

      #language {
          background: #00b093;
          color: #740864;
          padding: 0 5px;
          margin: 0 5px;
          min-width: 16px;
      }

      #keyboard-state {
          background: #97e1ad;
          color: #000000;
          padding: 0 0px;
          margin: 0 5px;
          min-width: 16px;
      }

      #keyboard-state>label {
          padding: 0 5px;
      }

      #keyboard-state>label.locked {
          background: rgba(0, 0, 0, 0.2);
      }

      #scratchpad {
          background: rgba(0, 0, 0, 0.2);
      }

      #scratchpad.empty {
          background-color: transparent;
      }

      #privacy {
          padding: 0;
      }

      #privacy-item {
          padding: 0 5px;
          color: white;
      }

      #privacy-item.screenshare {
          background-color: #cf5700;
      }

      #privacy-item.audio-in {
          background-color: #1ca000;
      }

      #privacy-item.audio-out {
          background-color: #0069d4;
      }
    '';
    xdg.configFile."waybar/config-bottom".text =
      builtins.toJSON config.programs.waybar.settings."config-bottom";
    xdg.configFile."waybar/config-bottom.css".text = ''
      * {
          /* `otf-font-awesome` is required to be installed for icons */
          /* font-family: FontAwesome, Roboto, Helvetica, Arial, sans-serif; */
          font-family: "Roboto", "Font Awesome 5 Free";
          font-size: 25px;
          margin: 5px;
      }

      window#waybar {
          background-color: rgba(43, 48, 59, 0.5);
          border-top: 3px solid rgba(100, 114, 125, 0.5);
          color: #ffffff;
          transition-property: background-color;
          transition-duration: .5s;
        padding-top: 10px;
        padding-bottom: 10px;
      }

      window#waybar.hidden {
          opacity: 0.2;
      }

      /*
      window#waybar.empty {
          background-color: transparent;
      }
      window#waybar.solo {
          background-color: #FFFFFF;
      }
      */

      window#waybar.termite {
          background-color: #3F3F3F;
      }

      window#waybar.chromium {
          background-color: #000000;
          border: none;
      }

      button {
          /* Use box-shadow instead of border so the text isn't offset */
          box-shadow: inset 0 -3px transparent;
          /* Avoid rounded borders under each button name */
          border: none;
          border-radius: 0;
      }

      /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
      button:hover {
          background: inherit;
          box-shadow: inset 0 -3px #ffffff;
      }

      #workspaces {
          padding: 15px;
      }

      #workspaces button {
          background-color: transparent;
          color: #ffffff;
      }

      #workspaces button:hover {
          background: rgba(0, 0, 0, 0.2);
      }

      #workspaces button.focused {
          background-color: #64727D;
          box-shadow: inset 0 -3px #ffffff;
      }

      #workspaces button.urgent {
          background-color: #eb4d4b;
      }

      #mode {
          background-color: #64727D;
          box-shadow: inset 0 -3px #ffffff;
      }

      #custom-media,
      #tray,
      #mode,
      #idle_inhibitor,
      #mpd {
          padding: 0 10px;
          color: #ffffff;
      }

      #window,
      #workspaces {
          margin: 0 4px;
      }

      /* If workspaces is the leftmost module, omit left margin */
      .modules-left>widget:first-child>#workspaces {
          margin-left: 0;
      }

      /* If workspaces is the rightmost module, omit right margin */
      .modules-right>widget:last-child>#workspaces {
          margin-right: 0;
      }

      #tray {
          background-color: #2980b9;
      }

      #tray>.passive {
          -gtk-icon-effect: dim;
      }

      #tray>.needs-attention {
          -gtk-icon-effect: highlight;
          background-color: #eb4d4b;
      }

      #idle_inhibitor {
          background-color: #2d3436;
      }

      #idle_inhibitor.activated {
          background-color: #ecf0f1;
          color: #2d3436;
      }

      #mpd {
          background-color: #66cc99;
          color: #2a5c45;
      }

      #mpd.disconnected {
          background-color: #f53c3c;
      }

      #mpd.stopped {
          background-color: #90b1b1;
      }

      #mpd.paused {
          background-color: #51a37a;
      }

      #privacy {
          padding: 0;
      }

      #privacy-item {
          padding: 0 5px;
          color: white;
      }

      #privacy-item.screenshare {
          background-color: #cf5700;
      }

      #privacy-item.audio-in {
          background-color: #1ca000;
      }

      #privacy-item.audio-out {
          background-color: #0069d4;
      }
    '' + "\n" + cssRules;

    xdg.configFile."waybar/icons" = {
      source = ./icons;
      recursive = true;
    };
  };
}

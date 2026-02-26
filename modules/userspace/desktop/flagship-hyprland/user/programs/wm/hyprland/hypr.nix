{ config, nixtraLib, lib, pkgs, ... }:

let
  backgroundConfig =
    if config.nixtra.desktop.flagship-hyprland.background.enable then ''
      windowrule = float, class:^${config.nixtra.desktop.flagship-hyprland.background.program}$
      windowrule = size 100% 100%, class:^${config.nixtra.desktop.flagship-hyprland.background.program}$
      windowrule = move 0 0, class:^${config.nixtra.desktop.flagship-hyprland.background.program}$
      windowrule = nofocus, class:^${config.nixtra.desktop.flagship-hyprland.background.program}$
      windowrule = noborder, class:^${config.nixtra.desktop.flagship-hyprland.background.program}$
      windowrule = noshadow, class:^${config.nixtra.desktop.flagship-hyprland.background.program}$
      windowrule = idleinhibit full, class:^${config.nixtra.desktop.flagship-hyprland.background.program}$ # Prevent idle actions
      layerrule = unset, class:^${config.nixtra.desktop.flagship-hyprland.background.program}$
      layerrule = noanim, class:^${config.nixtra.desktop.flagship-hyprland.background.program}$
      layerrule = order, -999
      windowrulev2 = immediate, class:^${config.nixtra.desktop.flagship-hyprland.background.program}$
      windowrulev2 = pin, class:^${config.nixtra.desktop.flagship-hyprland.background.program}$
      windowrulev2 = noinitialfocus, class:^(${config.nixtra.desktop.flagship-hyprland.background.program})$
    '' else
      "";

  startupConfig = lib.concatStringsSep "\n"
    (map (program: "exec-once = ${program}")
      config.nixtra.desktop.startupPrograms);

  defaultOpacity = "0.7";

  # Show GPU stats for AMDGPU.
  # TODO: When similar tools are created for other GPUs (NVIDIA, Intel...), add them here.
  mkSpecialWorkspace = { class, start, keybind, workspace
    , animation ? "top-bottom", opacity ? defaultOpacity, size ? "100% 100%"
    , float ? false, focus ? true }: ''
      workspace = special:${workspace}, on-created-empty: ${start}
      windowrule = workspace special:${workspace} silent, class:^${class}$
      windowrule = noborder, class:^${class}$
      ${lib.optionalString float ''
        windowrule = float, class:^${class}$
      ''}
      windowrule = idleinhibit full, class:^${class}$
      windowrule = noinitialfocus, class:^(${class})$
      ${lib.optionalString (!focus) ''
        windowrule = nofocus, class:^(${class})$
      ''}
      ${lib.optionalString (size != "") ''
        windowrule = size ${size}, class:^(${class})$
      ''}
      ${if (animation == "top-bottom") then ''
        animation = specialWorkspace, 1, 6, default, slidefadevert -50%
      '' else if (animation == "left-right") then ''
        animation = specialWorkspace, 1, 6, default, slidefade -50%
      '' else
        ""}
      windowrule = opacity ${opacity} override ${opacity} override ${opacity} override, workspace special:${workspace}, class:^(${class})$
      bind = ${keybind}, togglespecialworkspace, ${workspace}
      exec-once = ${start}
    '';

  profilerSpecialWorkspace = mkSpecialWorkspace {
    class = "amdgpu_top";
    start = "amdgpu_top --gui";
    keybind = "$mainMod, KP_Prior"; # 65434
    workspace = "stats";
    focus = false;
  };

  chatgptContainerSpecialWorkspace = mkSpecialWorkspace {
    class = "firefox";
    start = "firefox-chatgpt";
    keybind = "$mainMod, KP_End"; # 65436
    workspace = "ai";
  };

  waypaperSpecialWorkspace = mkSpecialWorkspace {
    class = "waypaper";
    start = "waypaper --backend swww --folder ~/Wallpapers";
    workspace = "wallpaper";
    keybind = "$mainMod, KP_Down";
    size = "";
    float = true;

    #animation = "left-right";
  };

  hyprshade-wrapped = pkgs.writeShellScriptBin "hyprshade" ''
    export PATH="${pkgs.hyprland}/bin:$PATH"
    exec ${pkgs.hyprshade}/bin/hyprshade "$@"
  '';

  play-startup-sound = (nixtraLib.command.createCommand {
    name = "play-startup-sound";
    prefix = "";

    command = ''
      # Wait until Hyprland is fully initialized
      while ! ${pkgs.hyprland}/bin/hyprctl monitors > /dev/null 2>&1; do
        sleep 1
      done

      ${pkgs.vlc}/bin/vlc --vout none --intf dummy ${
        ../../../../assets/audio/boot.mp3
      }
    '';
  });
in {
  config = lib.mkIf (config.nixtra.user.desktop == "flagship-hyprland") {
    home.packages = with pkgs;
      with hyprlandPlugins; [
        brightnessctl
        hyprtrails
        hypr-dynamic-cursors
      ];

    systemd.user.services.hyprshade = {
      Unit = {
        Description = "Hyprshade Service";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${hyprshade-wrapped}/bin/hyprshade auto";
        Restart = "on-failure";
        RestartSec = 1;
      };
    };

    systemd.user.timers.hyprshade = {
      Unit.Description = "Hyprshade Timer";
      Timer = {
        OnActiveSec = "1s";
        OnUnitActiveSec = "60s"; # Check every minute
        AccuracySec = "1s";
      };
      Install.WantedBy = [ "timers.target" ];
    };

    xdg.configFile."hypr/icons" = {
      source = ./icons;
      recursive = true;
    };

    xdg.configFile."hyprlock.conf".source = pkgs.writeText "hyprlock.conf" ''
      background {
          path = ${pkgs.nixos-artwork.wallpapers.simple-blue}/share/backgrounds/nixos/nixos-wallpaper-simple-blue.png
          color = rgba(0, 0, 0, 1.0)
      }

      input-field {
          size = 250, 50
          position = 0, -20
          halign = center
          valign = center
          outline_thickness = 2
          placeholder_text = <i>Enter Password...</i>
      }

      label {
          text = cmd[update:1000] echo "$(date +"%H:%M")"
          position = 0, 80
          halign = center
          valign = center
          font_size = 64
      }
    '';

    xdg.configFile."hypr/hyprshade.toml".source =
      pkgs.writeText "hyprshade.toml" ''
        [[shades]]
        name = "vibrance"
        default = true  # will be activated when no other shader is scheduled

        # This is no longer needed because of hyprsunset utility.
        #[[shades]]
        #name = "blue-light-filter"
        #start_time = 19:00:00
        #end_time = 06:00:00   # optional if more than one shader has start_time
      '';

    xdg.configFile."hypr/hyprsunset.conf".source =
      pkgs.writeText "hyprsunset.conf" ''
        max-gamma = 150

        profile {
            time = 7:00
            identity = true
        }

        profile {
            time = 17:00 # hyprsunset interprets as UTC time
            temperature = 5500
            gamma = 0.8
        }
      '';

    xdg.configFile."hypr/hyprland.conf".source =
      pkgs.writeText "hyprland.conf" ''
        autogenerated = 0

        # Refer to the wiki for more information.
        # https://wiki.hyprland.org/Configuring/Configuring-Hyprland/

        # You can split this configuration into multiple files
        # Create your files separately and then link them to this file like this:
        # source = ~/.config/hypr/myColors.conf

        ################
        ### MONITORS ###
        ################

        # See https://wiki.hyprland.org/Configuring/Monitors/
        monitor=,highrr,auto,auto


        ###################
        ### MY PROGRAMS ###
        ###################

        # See https://wiki.hyprland.org/Configuring/Keywords/

        # Set programs that you use
        $terminal = kitty
        $fileManager = dolphin
        $menu = wofi --show drun

        #############
        ### FIXES ###
        #############

        # Make programs work in systemd services
        exec-once = dbus-update-activation-environment --systemd --all

        # Make scheduling work; allow access to HYPRLAND_INSTANCE_SIGNATURE by systemd --user
        exec-once = dbus-update-activation-environment --systemd HYPRLAND_INSTANCE_SIGNATURE

        ###############
        ### PLUGINS ###
        ###############

        exec-once = hyprctl plugin load "$HYPR_PLUGIN_DIR/lib/libhyprspace.so"
        exec-once = hyprctl plugin load "$HYPR_PLUGIN_DIR/lib/libhyprtrails.so"
        exec-once = hyprctl plugin load "$HYPR_PLUGIN_DIR/lib/libhypr-dynamic-cursors.so"
        exec-once = hyprctl plugin load "$HYPR_PLUGIN_DIR/lib/libhyprfocus.so"

        plugin {
            overview {
                showEmptyWorkspace = false
                showNewWorkspace = false
            }

            hyprtrails {
                color = rgba(ffffff80)
            }

            dynamic-cursors {
                enabled = true
                mode = tilt

                shake {
                    enabled = false
                }
            }

            hyprfocus {
                enabled = yes

                keyboard_focus_animation = shrink
                mouse_focus_animation = flash

                bezier = bezIn, 0.5,0.0,1.0,0.5
                bezier = bezOut, 0.0,0.5,0.5,1.0

                flash {
                    flash_opacity = 0.7

                    in_bezier = bezIn
                    in_speed = 0.5

                    out_bezier = bezOut
                    out_speed = 3
                }

                shrink {
                    shrink_percentage = 0.8

                    in_bezier = bezIn
                    in_speed = 0.5

                    out_bezier = bezOut
                    out_speed = 3
                }
            }
        }

        #################
        ### AUTOSTART ###
        #################

        # Autostart necessary processes (like notifications daemons, status bars, etc.)
        # Or execute your favorite apps at launch like this:

        exec-once = systemctl --user start hyprpolkitagent.service
        exec-once = swww-daemon
        exec-once = ${play-startup-sound}/bin/play-startup-sound
        ${if config.nixtra.desktop.topbar.enable then ''
          exec-once = waybar -c ~/.config/waybar/config-top -s ~/.config/waybar/config-top.css
        '' else
          ""}
        ${if config.nixtra.desktop.taskbar.enable then ''
          exec-once = waybar -c ~/.config/waybar/config-bottom -s ~/.config/waybar/config-bottom.css
        '' else
          ""}
        exec-once = systemctl restart --user switch-wallpaper.service
        exec-once = systemctl restart --user rainbow-border.service

        # Clipboard history
        exec-once = wl-paste --type text --watch nixtra-check-cliphist-store
        exec-once = wl-paste --type image --watch nixtra-check-cliphist-store

        # Set cursor
        exec-once = hyprctl setcursor BreezeX-RosePine-Linux 24

        # Start shaders
        exec = hyprshade auto

        # Start screen annotator daemon
        exec-once = wayscriber --daemon

        # Start blue light filter
        exec-once = hyprsunset

        # Enable lockscreen when idle
        exec-once = swayidle -w \
          timeout 300 'hyprlock' \
          before-sleep 'hyprlock'
        exec-once = swayidle -w \
          timeout 1800 'sleep 5; hyprctl dispatch dpms off' \
          resume 'hyprctl dispatch dpms on'

        #############################
        ### ENVIRONMENT VARIABLES ###
        #############################

        # See https://wiki.hyprland.org/Configuring/Environment-variables/

        env = XCURSOR_SIZE,24
        env = HYPRCURSOR_SIZE,24

        # Fix user programs in NixOS sometimes not being in the path
        # `/run/wrappers/bin` is included to fix potential setuid error for sudo
        env = PATH,$PATH:/run/wrappers/bin:$HOME/.nix-profile/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/bin:/bin:/run/wrappers/bin

        #####################
        ### LOOK AND FEEL ###
        #####################

        layerrule = blur, waybar
        layerrule = ignorezero, waybar # ignore fully transparent pixels

        # Refer to https://wiki.hyprland.org/Configuring/Variables/

        # https://wiki.hyprland.org/Configuring/Variables/#general
        general {
            gaps_in = 10
            gaps_out = 20
            border_size = 3

            # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
            col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
            col.inactive_border = rgba(595959aa)

            # Set to true enable resizing windows by clicking and dragging on borders and gaps
            resize_on_border = true

            # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
            allow_tearing = false

            layout = dwindle
        }

        # https://wiki.hyprland.org/Configuring/Variables/#decoration
        decoration {
            rounding = 10

            # Change transparency of focused and unfocused windows
            active_opacity = 1.0
            inactive_opacity = 1.0

            shadow {
              enabled = true
              ${
                if config.nixtra.desktop.flagship-hyprland.rainbowShadow then ''
                  range = 50
                  render_power = 500
                '' else ''
                  range = 7
                  render_power = 2
                ''
              }
              #color = rgba(1a1a1aee)
              color = rgba(33ccffee)
            }

            # https://wiki.hyprland.org/Configuring/Variables/#blur
            blur {
                enabled = true
                vibrancy = 0.1696
                size = 5
                passes = 1
                #size = 2
                #passes = 3
                #blurls = waybar

                # these two fix an issue where the blur of windows sometimes goes away
                # when switching to a workspace, after 1 second
                ignore_opacity = true         # treats semi-transparent surfaces as blurable
                new_optimizations = false     # force correct repaints (can increase GPU load)
            }
        }

        # https://wiki.hyprland.org/Configuring/Variables/#animations
        animations {
            enabled = true

            # Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

            bezier = myBezier, 0.05, 0.9, 0.1, 1.05

            animation = windows, 1, 7, myBezier
            animation = windowsOut, 1, 7, default, popin 80%
            animation = border, 1, 10, default
            animation = borderangle, 1, 8, default
            animation = fade, 1, 7, default
            animation = workspaces, 1, 6, default

            # Rainbow border
            # https://www.reddit.com/r/hyprland/comments/13h6wb9/comment/jk52j2q
            bezier = linear, 0.0, 0.0, 1.0, 1.0
            animation = border, 1, 10, default
            animation = borderangle, 1, 100, linear, loop
        }

        # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
        dwindle {
            pseudotile = true # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
            preserve_split = true # You probably want this
        }

        # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
        master {
            new_status = master
        }

        # https://wiki.hyprland.org/Configuring/Variables/#misc
        misc {
            force_default_wallpaper = -1 # Set to 0 or 1 to disable the anime mascot wallpapers
            disable_hyprland_logo = false # If true disables the random hyprland logo / anime girl background. :(
            disable_splash_rendering = true
            enable_anr_dialog = false
        }


        #############
        ### INPUT ###
        #############

        # https://wiki.hyprland.org/Configuring/Variables/#input
        input {
            kb_layout = ${
              lib.concatStringsSep "," config.nixtra.desktop.languages
            }
            kb_variant = ,
            kb_model =
            kb_options = grp:alt_shift_toggle
            kb_rules =

            follow_mouse = 1

            accel_profile = flat # Disable mouse accel
            sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
            force_no_accel = true

            touchpad {
                natural_scroll = false
            }
        }

        # https://wiki.hyprland.org/Configuring/Variables/#gestures
        gesture = 3, horizontal, workspace

        # Example per-device config
        # See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more
        device {
            name = epic-mouse-v1
            sensitivity = -0.5
        }


        ###################
        ### KEYBINDINGS ###
        ###################

        # See https://wiki.hyprland.org/Configuring/Keywords/
        $mainMod = SUPER # Sets "Windows" key as main modifier

        bind = $mainMod, Q, exec, $terminal
        bind = $mainMod, C, exec, hyprpicker --autocopy
        bind = $mainMod SHIFT, M, exit,
        bind = $mainMod, E, exec, $fileManager
        bind = $mainMod, V, togglefloating,
        bind = $mainMod, R, exec, $menu
        bind = $mainMod, P, pseudo,
        bind = $mainMod, N, togglesplit,
        bind = $mainMod SHIFT, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy

        # Move the hovered window left/right/up/down
        bind = $mainMod SHIFT, H, movewindow, l
        bind = $mainMod SHIFT, L, movewindow, r
        bind = $mainMod SHIFT, K, movewindow, u
        bind = $mainMod SHIFT, J, movewindow, d

        # Scale the hovered window left/right/up/down
        bindel = $mainMod SHIFT ALT, l, resizeactive, 20 0
        bindel = $mainMod SHIFT ALT, h, resizeactive, -20 0
        bindel = $mainMod SHIFT ALT, k, resizeactive, 0 -20
        bindel = $mainMod SHIFT ALT, j, resizeactive, 0 20

        # Control volume
        bind = $mainMod, left, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-
        bind = $mainMod, right, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
        bind = $mainMod, down, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

        # Control brightness
        bind = $mainMod SHIFT, left, exec, brightnessctl set 10%-
        bind = $mainMod SHIFT, right, exec, brightnessctl set +10%

        # Move focus with mainMod + arrow keys
        bind = $mainMod, H, movefocus, l
        bind = $mainMod, L, movefocus, r
        bind = $mainMod, K, movefocus, u
        bind = $mainMod, J, movefocus, d

        # # Switch workspaces with mainMod + [0-9]
        # bind = $mainMod, 1, workspace, 1
        # bind = $mainMod, 2, workspace, 2
        # bind = $mainMod, 3, workspace, 3
        # bind = $mainMod, 4, workspace, 4
        # bind = $mainMod, 5, workspace, 5
        # bind = $mainMod, 6, workspace, 6
        # bind = $mainMod, 7, workspace, 7
        # bind = $mainMod, 8, workspace, 8
        # bind = $mainMod, 9, workspace, 9
        # bind = $mainMod, 0, workspace, 10
        # bind = $mainMod CONTROL_L, 1, workspace, 11
        # bind = $mainMod CONTROL_L, 2, workspace, 12
        # bind = $mainMod CONTROL_L, 3, workspace, 13
        # bind = $mainMod CONTROL_L, 4, workspace, 14
        # bind = $mainMod CONTROL_L, 5, workspace, 15
        # bind = $mainMod CONTROL_L, 6, workspace, 16
        # bind = $mainMod CONTROL_L, 7, workspace, 17
        # bind = $mainMod CONTROL_L, 8, workspace, 18
        # bind = $mainMod CONTROL_L, 9, workspace, 19
        # bind = $mainMod CONTROL_L, 0, workspace, 20

        # # Move active window to a workspace with mainMod + SHIFT + [0-9]
        # bind = $mainMod SHIFT, 1, movetoworkspace, 1
        # bind = $mainMod SHIFT, 2, movetoworkspace, 2
        # bind = $mainMod SHIFT, 3, movetoworkspace, 3
        # bind = $mainMod SHIFT, 4, movetoworkspace, 4
        # bind = $mainMod SHIFT, 5, movetoworkspace, 5
        # bind = $mainMod SHIFT, 6, movetoworkspace, 6
        # bind = $mainMod SHIFT, 7, movetoworkspace, 7
        # bind = $mainMod SHIFT, 8, movetoworkspace, 8
        # bind = $mainMod SHIFT, 9, movetoworkspace, 9
        # bind = $mainMod SHIFT, 0, movetoworkspace, 10

        # Example special workspace (scratchpad)
        #bind = $mainMod, S, togglespecialworkspace, magic

        # Cycle through next and previous workspaces
        bind = $mainMod, period, workspace, e+1
        bind = $mainMod, comma, workspace, e-1

        # Move/resize windows with mainMod + LMB/RMB and dragging
        bindm = $mainMod, mouse:272, movewindow
        bindm = $mainMod, mouse:273, resizewindow

        # Fullscreen
        bind = $mainMod, F, fullscreen,

        # Screenshot
        bind = $mainMod,S,exec,nixtra-screenshot
        bind = $mainMod SHIFT, S, exec, nixtra-screenshot region

        # Record
        bind = $mainMod,R,exec,nixtra-record toggle fullscreen
        bind = $mainMod SHIFT, R, exec, nixtra-record toggle region

        # Open applications without terminal (app launcher)
        bind = $mainMod,space,exec,rofi -show drun -run-shell-command 'kitty --hold {cmd}'

        # Switch windows without mouse
        bind = ALT, K, focuswindow, next
        bind = ALT, J, focuswindow, previous

        # Jump to previous workspace
        bind = ALT, TAB, exec, hyprctl dispatch workspace previous

        # Open workspace manager (hyprspace)
        bind = $mainMod, G, exec, hyprctl dispatch overview:toggle

        # Activate lock screen
        bind = $mainMod, F12, exec, hyprlock

        # Bind personal applications to workspaces
        ${builtins.concatStringsSep "\n" (lib.imap1 (i: workspace:
          let
            programs = (map (program: "${program}.desktop") workspace.programs)
              ++ workspace.programs;
          in builtins.concatStringsSep "\n" (map (program:
            "windowrule = workspace ${
              builtins.toString i
            },class:${program} # ${workspace.name}") programs))
          config.nixtra.desktop.flagship-hyprland.workspaces)}

        # Close windows
        bind = $mainMod,Z,killactive

        # Open screen annotator
        bind = $mainMod, KP_Left, exec, pkill -SIGUSR1 wayscriber

        ##############################
        ### WINDOWS AND WORKSPACES ###
        ##############################

        # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
        # See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

        windowrulev2 = suppressevent maximize, class:.* # You'll probably like this.

        # Transparency
        windowrule = opacity ${defaultOpacity} override ${defaultOpacity} override,title:.*
        windowrule = opacity 1.0 override 1.0 override,class:^(kitty)$

        # Disable border if only one app is opened in a workspace
        #windowrulev2 = noborder,onworkspace:1

        # Instantly disable border for unfocused apps
        #windowrulev2 = noborder, focus:0

        # Instantly disable shadow for unfocused apps
        ${if config.nixtra.desktop.flagship-hyprland.rainbowBorder then ''
          windowrulev2 = noshadow, focus:0
        '' else
          ""}

        # https://github.com/hyprwm/Hyprland/issues/6612#issuecomment-2613661667
        #workspace = w[t1], gapsout:0
        # Disable border if only one app is opened in a workspace
        workspace = w[t1], border:0

        # Disable shadow if only one app is opened in a workspace
        ${if config.nixtra.desktop.flagship-hyprland.rainbowBorder then ''
          workspace = w[t1], shadow:0
        '' else
          ""}

        # Gromit for Wayland
        # https://www.reddit.com/r/hyprland/comments/18kutkk/gromitmpx_configuration
        #
        # Gromit-mpx is no longer used because of an issue on Wayland where it hijacks
        # the mouse input of other applications, preventing you from clicking things on them:
        # https://github.com/bk138/gromit-mpx/issues/136
        #
        # Wayscriber is used instead, a modern alternative for Wayland compositors.
        #
        # workspace = special:gromit, gapsin:0, gapsout:0, shadow:false, on-created-empty: gromit-mpx -a
        # windowrule = noblur, class:^(Gromit-mpx)$
        # windowrule = opacity override 1, class:^(Gromit-mpx)$
        # windowrule = noshadow, class:^(Gromit-mpx)$
        # windowrule = suppressevent fullscreen, class:^(Gromit-mpx)$
        # windowrule = size 100% 100%, class:^(Gromit-mpx)$
        # bind = $mainMod, KP_Left, togglespecialworkspace, gromit
        # bind = $mainMod, KP_Begin, exec, gromit-mpx --clear
        # bind = Control_L, Z, exec, desktop-run-if-active "special:gromit" "gromit-mpx --undo"

        # -------

        # Special workspaces
        ${profilerSpecialWorkspace}
        ${chatgptContainerSpecialWorkspace}
        ${waypaperSpecialWorkspace}

        # Startup programs config
        ${startupConfig}
      '';
  };
}

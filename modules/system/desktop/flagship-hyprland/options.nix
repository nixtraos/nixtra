{ lib, nixtraLib, ... }:

let
  inherit (nixtraLib.option) mkNixtraOption;

  idleKillerConcurrentAppSubmodule = lib.types.submodule {
    options = {
      class = lib.mkOption {
        type = lib.types.str;
        description = "The class name of the application";
      };
      timeout = lib.mkOption {
        type = lib.types.int;
        description =
          "The time (in seconds) that the app needs to be inactive for to be stopped";
      };
    };
  };
in {
  options.nixtra.desktop."flagship-hyprland" = {
    background = {
      enable = nixtraLib.option.mkNixtraOption lib.types.bool false
        "Whether to enable an animated background program.";
      program = nixtraLib.option.mkNixtraOption lib.types.str "amdgpu_top" ''
        The program to use as an animated background.
        This should be set to the class of the desired program.
        Get the class of a program in Hyprland with `hyprctl active-window`.
      '';
    };

    rainbowBorder = nixtraLib.option.mkNixtraOption lib.types.bool true
      "Whether to enable a rainbow window border.";
    rainbowShadow = nixtraLib.option.mkNixtraOption lib.types.bool true
      "Whether to enable rainbow window shadows.";

    workspaces = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Workspace name";
          };
          icon = lib.mkOption {
            type = lib.types.str;
            description = "The icon to use to display the workspace";
          };
          programs = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description =
              "The programs (their classes) to reside in the workspace";
          };
        };
      });
      default = [
        {
          name = "Terminal";
          icon = "";
          programs = [ "kitty" "alacritty" ];
        }
        {
          name = "Clearnet Browser";
          icon = "";
          programs = [ "firefox" "librewolf" "chrome" ];
        }
        {
          name = "Video Player";
          icon = "";
          programs = [ "FreeTube" "vlc" "mpv" "com.stremio.stremio" ];
        }
        {
          name = "Anonymous Browser";
          icon = "";
          programs = [ "Tor Browser" ];
        }
        {
          name = "Code Editor";
          icon = "";
          programs = [ "lvim" "vim" "nvim" "codium" ];
        }
        {
          name = "Virtual Machine";
          icon = "";
          programs = [ ".virt-manager-wrapped" "com.usebottles.bottles" ];
        }
        {
          name = "Communication";
          icon = "";
          programs = [ "element-desktop" "discord" "so.libdb.dissent" ];
        }
        {
          name = "Gaming";
          icon = "";
          programs = [
            "org.prismlauncher.PrismLauncher"
            "org.prismlauncher.EntryPoint"
            "org.prismlauncher-EntryPoint"
            "steam"
            "net.lutris.Lutris"
            "^(Minecraft.*)$"
          ];
        }
        {
          name = "Document Viewer";
          icon = "";
          programs = [
            "Zettlr"
            "io.github.alainm23.planify"
            "libreoffice-startcenter"
            "org.kde.okular"
            "io.gitlab.news_flash.NewsFlash"
            "kiwix"
            "libreoffice-writer"
          ];
        }
        {
          name = "Drawing & Presentation";
          icon = "";
          programs = [ "krita" "gimp" "org.oe-f." ];
        }
        {
          name = "Download";
          icon = "";
          programs = [ "org.qbittorrent.qBittorrent" ];
        }
        {
          name = "Email";
          icon = "";
          programs = [ "thunderbird" ];
        }
        {
          name = "Password Manager";
          icon = "";
          programs = [ "org.keepassxc.KeePassXC" ];
        }
      ];
    };

    idleKiller = {
      enable = mkNixtraOption lib.types.bool true
        "Whether to enable Idle Killer; check for inactive apps and stop them automatically";
      pollInterval = mkNixtraOption lib.types.int 5
        "How often (in seconds) to poll focused app and update timers";
      defaultTimeout = mkNixtraOption lib.types.int (30 * 60)
        "Default timeout (in seconds) for apps not explicitly listed";
      appTimeouts =
        mkNixtraOption (lib.types.listOf idleKillerConcurrentAppSubmodule) [{
          class = "firefox";
          timeout = 600;
        }]
        "Apps that should be checked for inactivity concurrently; with a separate timer";
      killMethod = mkNixtraOption (lib.types.enum [ "pid" "pkill" ]) "pid"
        "The kill method that should be used to stop apps";
      killGrace = mkNixtraOption lib.types.int 30
        "How long to wait after SIGTERM before SIGKILL (in seconds)";
      hyprctlBatch = mkNixtraOption lib.types.bool false
        "Whether the service should optimize hyprctl calls per loop to avoid spamming compositor. The scripts already minimize hyprctl calls by caching results per loop, so this should not be needed.";
    };
  };
}

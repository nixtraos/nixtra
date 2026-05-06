{ config, pkgs, ... }:

let
  newline = {
    type = "custom";
    format = "";
  };

  totalLocWithNewlines = "${pkgs.findutils}/bin/find /etc/nixos -name '*.nix' -type f -exec cat {} + | wc -l";
  totalLocWithoutNewlines = "${pkgs.findutils}/bin/find /etc/nixos -name '*.nix' -type f -exec cat {} + | grep -cve '^\\s*$'";
  totalNewlinesLoc = "${pkgs.findutils}/bin/find /etc/nixos -name '*.nix' -type f -exec cat {} + | grep -c '^\\s*$'";
in
{
  programs.fastfetch = {
    enable = true;

    settings = {
      display = {
        color = {
          keys = "37";
          output = "37";
        };
        separator = " ➜  ";
      };

      logo = {
        source = ../../../../shared-assets/icons/logo.png;
        type = "kitty-direct";
        height = 10;
        width = 20;
        padding = {
          top = 2;
          left = 2;
        };
      };

      modules = [
        "break"
        {
          type = "os";
          key = "OS — Nixtra";
          keyColor = "31";
        }
        {
          type = "kernel";
          key = " ├  ";
          keyColor = "31";
        }
        {
          type = "packages";
          key = " ├ 󰏖 ";
          keyColor = "31";
        }
        {
          type = "shell";
          key = " └  ";
          keyColor = "31";
        }
        "break"
        {
          type = "wm";
          key = "WM   ";
          keyColor = "32";
        }
        {
          type = "wmtheme";
          key = " ├ 󰉼 ";
          keyColor = "32";
        }
        {
          type = "icons";
          key = " ├ 󰀻 ";
          keyColor = "32";
        }
        {
          type = "cursor";
          key = " ├  ";
          keyColor = "32";
        }
        {
          type = "terminal";
          key = " ├  ";
          keyColor = "32";
        }
        {
          type = "terminalfont";
          key = " └  ";
          keyColor = "32";
        }
        "break"
        {
          type = "host";
          format = "{5} {1} Type {2}";
          key = "PC   ";
          keyColor = "33";
        }
        {
          type = "cpu";
          format = "{1} ({3}) @ {7} GHz";
          key = " ├  ";
          keyColor = "33";
        }
        {
          type = "gpu";
          format = "{1} {2} @ {12} GHz";
          key = " ├ 󰢮 ";
          keyColor = "33";
        }
        {
          type = "memory";
          key = " ├  ";
          keyColor = "33";
        }
        {
          type = "disk";
          key = " ├ 󰋊 ";
          keyColor = "33";
        }
        {
          type = "monitor";
          key = " ├  ";
          keyColor = "33";
        }
        "break"
        {
          type = "uptime";
          key = "   Uptime   ";
        }
        {
          type = "custom";
          key = "   Lines of Code";
          exec = ''
            bash -c '
              totalLines=$(${totalLocWithoutNewlines})
              blankLines=$(${totalNewlinesLoc})
              echo "$totalLines ($blankLines blank lines)"
            '
          '';
          #postProcess = "trim";
        }
        "break"
        {
          type = "custom";
          format = " https://github.com/quarterstar/nixtra";
        }
      ];
    };
  };
}

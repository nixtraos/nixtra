{ config, lib, ... }:

{
  config = lib.mkIf (config.nixtra.user.desktop == "flagship-hyprland") {
    programs.kitty = {
      # Fix for https://discourse.nixos.org/t/kitty-0-30-1-lib-kitty-terminfo-command-not-found/34071/2
      # lib/kitty/terminfo: command not found
      # https://github.com/NixOS/nixpkgs/issues/260427#issuecomment-1794548912
      shellIntegration.mode = "no-sudo";

      settings = {
        shell = config.nixtra.user.shell.backend;
        background_opacity = 0.0;
        background_blur = 1;
        dynamic_background_opacity = true;
        confirm_os_window_close = 0;
        scrollback_lines = 10000;
        enable_audio_bell = false;
        update_check_interval = 0;
      };

      keybindings = {
        "ctrl+tab" = "send_text normal,application \\x1b[9;5u";
        "ctrl+shift+tab" = "send_text normal,application \\x1b[9;6u";
      };
    };
  };
}

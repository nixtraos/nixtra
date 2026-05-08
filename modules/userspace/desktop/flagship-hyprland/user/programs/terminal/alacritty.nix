{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf (config.nixtra.user.desktop == "flagship-hyprland") {
    programs.alacritty = {
      enable = true;
      settings = {
        terminal.shell = {
          program = "tmux";
        };

        window = {
          opacity = 0.0;
        };
      };
    };
  };
}

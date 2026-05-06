{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf (config.nixtra.user.terminal == "kitty") {
    home.packages = with pkgs; [ kitty ];

    programs.kitty.enable = true;
  };
}

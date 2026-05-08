{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf (config.nixtra.user.terminal == "alacritty") {
    programs.alacritty.enable = true;
  };
}

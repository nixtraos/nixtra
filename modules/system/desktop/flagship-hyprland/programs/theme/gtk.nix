{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf (config.nixtra.user.desktop == "flagship-hyprland") {
    environment.systemPackages = with pkgs; [
      rose-pine-cursor
      rose-pine-hyprcursor
    ];
  };
}

{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf config.nixtra.desktop.enable {
    environment.systemPackages = with pkgs; [ systembus-notify ];
    services.systembus-notify.enable = true;
  };
}

{
  config,
  nixtraLib,
  lib,
  pkgs,
  ...
}:

let
  inherit (nixtraLib.command) createCommand;
in
{
  config = lib.mkIf (config.nixtra.user.desktop == "flagship-hyprland") {
    home.packages = [
      (pkgs.callPackage ./schedule-reminder.nix { inherit createCommand; })
      (pkgs.callPackage ./run-if-active.nix { inherit createCommand; })
    ];
  };
}

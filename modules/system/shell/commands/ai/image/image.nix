{
  config,
  pkgs,
  lib,
  nixtraLib,
  ...
}:

let
  inherit (nixtraLib.command) createCommand;
in
{
  config = lib.mkIf config.nixtra.shell.commands.enable {
    environment.systemPackages = [
      (pkgs.callPackage ./remove-background.nix { inherit pkgs createCommand; })
      (pkgs.callPackage ./upscale.nix { inherit pkgs createCommand; })
    ];
  };
}

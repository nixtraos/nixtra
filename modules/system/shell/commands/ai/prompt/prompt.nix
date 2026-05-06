{
  config,
  lib,
  nixtraLib,
  pkgs,
  ...
}:

let
  inherit (nixtraLib.command) createCommand;
in
{
  config = lib.mkIf config.nixtra.shell.commands.enable {
    environment.systemPackages = [
      (pkgs.callPackage ./context-builder.nix { inherit config pkgs createCommand; })
    ];
  };
}

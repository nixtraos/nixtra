{
  pkgs,
  lib,
  config,
  nixtraLib,
  ...
}:

let
  inherit (nixtraLib.command) createCommand;
in
{
  config = lib.mkIf config.nixtra.shell.commands.enable {
    environment.systemPackages = [
      (pkgs.callPackage ./cli.nix { inherit pkgs createCommand; })
      (pkgs.callPackage ./load.nix { inherit pkgs createCommand; })
    ];
  };
}

{
  config,
  lib,
  nixtraLib,
  ...
}:

let
  inherit (nixtraLib.command) createCommand;
in
{
  config = lib.mkIf config.nixtra.security.apparmor.enable {
    environment.systemPackages = [ (import ./generate-config.nix { inherit createCommand; }) ];
  };
}

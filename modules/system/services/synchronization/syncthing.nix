{ config, lib, ... }:

{
  config = lib.mkIf config.nixtra.syncthing.enable {
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      settings = {
        gui.user = "user";
      };
    };
  };
}

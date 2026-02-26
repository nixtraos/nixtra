{ config, lib, ... }:

{
  config = lib.mkIf config.nixtra.performance.monitorServices {
    services.monit = { enable = true; };
  };
}

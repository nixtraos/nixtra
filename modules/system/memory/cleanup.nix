{ config, lib, ... }:

let
  cfg = config.nixtra.memory.automaticCleanupServices;
in
{
  systemd.services = lib.mkMerge (
    map (service: {
      service = {
        serviceConfig = {
          MemoryMax = "${builtins.toString service.maximumMemory}M";
          MemorySwapMax = "${builtins.toString service.maximumSwapMemory}M";
          RuntimeMaxSec = "${builtins.toString service.restartAfter}m";
        };
      };
    }) cfg
  );
}

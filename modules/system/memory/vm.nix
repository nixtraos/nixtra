{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.nixtra.memory.autoCleanVmCache {
    systemd.services.clear-vm-cache = {
      description = "Clear VM Cache";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c 'sync; echo 3 > /proc/sys/vm/drop_caches'";
      };
    };

    systemd.timers.clear-vm-cache = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "60s";
        OnUnitActiveSec = "60s";
        Unit = "clear-vm-cache.service";
      };
    };
  };
}

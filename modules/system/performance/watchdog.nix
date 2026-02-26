{ config, lib, ... }:

{
  config = lib.mkIf (config.nixtra.performance.watchdog) {
    services.watchdogd.enable = true;

    services.watchdogd.settings = {
      timeout = 15; # WDT timeout in seconds (before reset)
      interval = 5; # how often watchdogd kicks the timer
      "safe-exit" = true; # try to disable WDT when the daemon stops
      filenr = {
        enabled = true;
        interval = 300;
        warning = 0.9;
        critical = 1.0;
      };
      loadavg = {
        enabled = true;
        interval = 300;
        warning = 1.0;
        critical = 2.0;
      };
      meminfo = {
        enabled = true;
        interval = 300;
        warning = 0.9;
        critical = 0.95;
      };
    };
  };
}

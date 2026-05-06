{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.nixtra.performance.preventOutOfMemoryPanic {
    services.earlyoom = {
      enable = true;
      enableNotifications = true;
    };
  };
}

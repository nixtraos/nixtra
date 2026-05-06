{
  config,
  lib,
  pkgs,
  ...
}:

{
  config =
    lib.mkIf (config.nixtra.monitoring.enable && config.nixtra.monitoring.stack == "prometheus-grafana")
      {
        services.loki = {
          enable = true;
          configFile = ./loki-local-config.yaml;
        };
      };
}

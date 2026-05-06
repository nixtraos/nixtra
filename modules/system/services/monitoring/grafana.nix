{ config, lib, ... }:

{
  config = lib.mkIf config.nixtra.monitoring.enable {
    # Use Grafana for the Dashboard
    services.grafana = lib.mkIf (config.nixtra.monitoring.stack == "prometheus-grafana") {
      enable = true;
      settings.server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
      };
    };
  };
}

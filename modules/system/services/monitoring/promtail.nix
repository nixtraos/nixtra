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
        systemd.services.promtail = {
          description = "Promtail service for Loki";
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            ExecStart = ''
              ${pkgs.grafana-loki}/bin/promtail --config.file ${./promtail.yaml}
            '';
          };
        };
      };
}

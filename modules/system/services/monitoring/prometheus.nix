{
  config,
  lib,
  inputs,
  unstable-pkgs,
  ...
}:

{
  disabledModules = [ "services/monitoring/prometheus/default.nix" ];

  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/monitoring/prometheus/default.nix"
  ];

  config =
    lib.mkIf (config.nixtra.monitoring.enable && config.nixtra.monitoring.stack == "prometheus-grafana")
      {
        # NOTE: Upstream Prometheus is replaced because its .tar.gz release currently leads to a 404 in the latest stable release of NixOS.
        # nixpkgs.overlays = [
        #   (final: prev: {
        #     # Force node_exporter back to a version that exists
        #     prometheus-node-exporter = prev.prometheus-node-exporter.overrideAttrs
        #       (oldAttrs: rec {
        #         version = "1.8.2";
        #         src = prev.fetchFromGitHub {
        #           owner = "prometheus";
        #           repo = "node_exporter";
        #           rev = "v${version}";
        #           sha256 = "sha256-b2uior67RcCCpUE+qx55G1eWiT2wWDVsnosSH9fd3/I=";
        #         };
        #         vendorHash = "sha256-sly8AJk+jNZG8ijTBF1Pd5AOOUJJxIG8jHwBUdlt8fM=";
        #       });
        #   })
        # ];

        # Use Prometheus to scrape and store data
        services.prometheus = lib.mkIf (config.nixtra.monitoring.stack == "prometheus-grafana") {
          package = unstable-pkgs.prometheus;
          enable = true;
          port = 9090;
          scrapeConfigs = [
            {
              job_name = "nixos-pc";
              static_configs = [
                {
                  targets = [
                    "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
                  ];
                }
              ];
            }
          ];
          # Use Node Exporter to gather metrics
          exporters.node = {
            enable = true;
            enabledCollectors = [ "systemd" ];
            port = 9100;
          };
        };
      };
}

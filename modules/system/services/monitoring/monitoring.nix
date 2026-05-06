# Useful resources:
# - https://xeiaso.net/blog/prometheus-grafana-loki-nixos-2020-11-20/
# - https://gist.github.com/globin/02496fd10a96a36f092a8e7ea0e6c7dd

{ ... }:

{
  imports = [
    ./prometheus.nix
    ./grafana.nix
    ./loki.nix
    ./promtail.nix
  ];
}

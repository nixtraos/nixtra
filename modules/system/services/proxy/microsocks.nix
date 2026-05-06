{
  config,
  pkgs,
  lib,
  ...
}:

{
  systemd.user.services = builtins.listToAttrs (
    (map (
      proxy:
      let
        config = pkgs.writeText "proxychains-${proxy.tag}.conf" (
          ''
            # Ensure that traffic will not be sent if any of the proxies in the below chain are not currently functional.
            strict_chain

            # Make proxy-related logging not appear.
            quiet_mode
                
            # Proxy all DNS queries through the proxychain
            proxy_dns

            # Public proxy may take time to load
            tcp_read_time_out 30000
            tcp_connect_time_out 30000

            # The proxy chain list
            [ProxyList]
          ''
          + (lib.concatStringsSep "\n" (
            map (entry: "${entry.type} ${entry.address} ${builtins.toString entry.port}") proxy.entries
          ))
        );
      in
      {
        name = "microsocks-${proxy.tag}";
        value = {
          enable = true;
          description = "MicroSocks SOCKS5 Proxy";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            ExecStart = "${pkgs.proxychains}/bin/proxychains4 -f ${config} ${pkgs.microsocks}/bin/microsocks -p ${builtins.toString proxy.port}";
            Restart = "on-failure";
            RestartSec = "5s";
          };
        };
      }
    ) config.nixtra.microsocks.services)
  );
}

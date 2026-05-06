{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.nixtra.tor.enable {
    # Stub service
    # This is done so that the tor user is created and managed by NixOS
    services.tor = {
      enable = true;
      #torsocks.enable = true;
      settings.SOCKSPort = 9000;
    };

    systemd.services = builtins.listToAttrs (
      map (service: {
        name = "tor-${service.tag}";
        value = {
          description = "Tor Service";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            # systemd manages the folder and permissions automatically
            StateDirectory = "tor-${service.tag}";

            ExecStart = "${pkgs.tor}/bin/tor -f ${pkgs.writeText "torrc1" ''
              SocksPort ${builtins.toString service.port}
              ControlPort 0

              # use the directory systemd manages for us instead
              #DataDirectory /home/tor/tor-${service.tag}
              DataDirectory /var/lib/tor-${service.tag}
            ''}";
            Type = "simple";
            User = "tor";
            Group = "tor";
            Restart = "on-failure";
            RestartSec = "30s";

            # Hardening
            ProtectSystem = "full";
            ProtectHome = "yes";
            NoNewPrivileges = true;
          };
        };
      }) config.nixtra.tor.services
    );

    # Ensure the data directories exist and have the correct permissions
    # system.activationScripts.torSetup = lib.concatStringsSep "\n" (map
    #   (service: ''
    #     mkdir -p /home/tor-${service.tag}
    #     chown -R tor:tor /home/tor-${service.tag}
    #   '') config.nixtra.tor.services);
  };
}

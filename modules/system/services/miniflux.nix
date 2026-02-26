{ config, ... }:

let ports = { miniflux = 8070; };
in {
  services.miniflux = {
    enable = true;
    adminCredentialsFile =
      config.sops.secrets.${config.nixtra.miniflux.adminSecret}.path;
    config = {
      LISTEN_ADDR = "127.0.0.1:${builtins.toString ports.miniflux}";
      BASE_URL = "http://search/miniflux/";
      RUN_MIGRATIONS = 1;
    };
  };

  services.postgresql.authentication = "local all all trust";

  services.nginx = {
    virtualHosts = {
      "rss" = {
        locations = {
          "/".proxyPass =
            "http://localhost:${builtins.toString ports.miniflux}/miniflux/";
        };
      };
    };
  };
}

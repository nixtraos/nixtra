{ config, pkgs, ... }:

{
  services = {
    elasticsearch = {
      enable = true;
      package = pkgs.elasticsearch;
      settings = {
        "cluster.name" = "graylog-cluster";
        "node.name" = "graylog-node-1";
        "network.host" = "127.0.0.1";
        "http.port" = 9200;
        "transport.host" = "127.0.0.1";
        "transport.tcp.port" = 9300;
        "xpack.security.enabled" = false; # Disable for initial setup, enable for production
        "discovery.type" = "single-node"; # For single node setup
        "jvm.options" = [
          "-Xms2g"
          "-Xmx2g"
        ];
      };
      # If you need plugins, define them here:
      # plugins = [
      #   pkgs.elasticsearch8Plugins.ingest-attachment
      # ];
    };

    mongodb = {
      enable = true;
      port = 27017;
      # dataDir = "/var/lib/mongodb";
    };

    graylog = {
      enable = true;
      package = pkgs.graylog-6_1;
      # pwgen -N 1 -s 96
      passwordSecret = "YOUR_PASSWORD_SECRET_HERE";
      # echo -n "yourpassword" | sha256sum
      rootPasswordSha2 = "YOUR_ROOT_PASSWORD_SHA2_HERE";
      #rootEmail = "admin@example.com"; # Optional

      # WebIF settings
      webListenUri = "http://127.0.0.1:9000/";
      httpListenUri = "http://127.0.0.1:9000/"; # Graylog REST API endpoint

      elasticsearchHosts = [ "http://127.0.0.1:9200" ];
      # Elasticsearch indices (optional, usually good defaults)
      elasticsearchIndexPrefix = "graylog";
      elasticsearchShards = 1; # For single node
      elasticsearchReplicas = 0; # For single node

      # Connect to MongoDB
      mongodbUri = "mongodb://127.0.0.1:27017/graylog";

      # JVM options for Graylog (adjust based on your available RAM)
      extraConfig = ''
        java_opts = "-Xms1g -Xmx1g"
      '';
    };
  };

  # Open firewall ports
  networking.firewall.allowedTCPPorts = [
    9000 # Graylog Web Interface / REST API
    9200 # Elasticsearch HTTP
    27017 # MongoDB
    # Graylog input ports (e.g., Syslog UDP) - add as needed
    # 514 # Syslog UDP
    # 1514 # Syslog TCP
    # 12201 # GELF UDP
    # 12202 # GELF TCP
  ];
}

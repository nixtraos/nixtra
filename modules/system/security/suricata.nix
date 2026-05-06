{
  services.suricata = {
    enable = true;

    # Network interface Suricata should monitor
    interface = "eth0"; # Change this to your actual interface name, e.g., wlan0, enp3s0, etc.

    # Additional options, like configuration file path or rule files, can be specified here
    #configFile = "/etc/suricata/suricata.yaml";  # Usually default

    # Optional: enable IPS mode (blocking), default is IDS mode (monitor only)
    #mode = "inline";

    # Optional logging options
    logDir = "/var/log/suricata";

    # You can also specify Suricata rules here or mount rules from another source
    #rules = [ "/path/to/custom.rules" ];
  };
}

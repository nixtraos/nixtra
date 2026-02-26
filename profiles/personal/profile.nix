# Everything defined here is added to `config.nixtra`.
# See configuration documentation for more information.
# This configuration is specific to the machine of the
# person whose repository you obtained it from. You
# should make your own profile from scratch for your
# own machine.

{ config, pkgs, ... }:

{
  hardware = {
    cpu = "amd";
    gpu = "amd";
  };

  disk = {
    partitions = {
      boot = "/dev/disk/by-uuid/12CE-A600";
      storage = "/dev/disk/by-uuid/75f7fad7-0065-49a1-950c-ba5913eeae83";
    };

    encryption = {
      enable = true;
      decryptedRootDevice =
        "/dev/disk/by-uuid/ce341f6f-8daf-43d0-a034-901c93654118";
    };
  };

  desktop = {
    startupPrograms =
      [ "keepassxc" config.nixtra.user.terminal config.nixtra.user.browser ];
  };

  security = {
    kernel = {
      aggressivePanic = false;
      veryAggressivePanic = false;
      mitigateCommonVulnerabilities = false;
      enforceDmaProtection = false;
      requireSignatures = false;
      encryptMemory = false;
    };

    siem = { zeek = { interface = "enp24s0"; }; };

    vpn = {
      enable = true;
      type = "mullvad";
    };

    sops = {
      keys = {
        "password" = { neededForUsers = true; };
        "ssh/hosts/laptop/publicKey" = { neededForUsers = true; };
        "searx/secret" = { neededForUsers = true; };
        "miniflux/admin" = {
          format = "dotenv";
          sopsFile = ../../secrets/miniflux.env;
          restartUnits = [ "miniflux.service" ];
        };
      };
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [ 2121 ];
    };

    virtualization = true;
  };

  performance = { monitorServices = false; };

  ssh = {
    enable = true;
    hosts = {
      "laptop" = {
        hostNames = [ "192.168.1.203" ];
        publicKeySecret = "ssh/laptop/publicKey";
        profile = "laptop";
      };
    };
  };

  searx = { secretPath = "searx/secret"; };

  scheduledTasks = [
    # {
    #   enable = true;
    #   name = "system-shutdown";
    #   time = "23:00";
    #   action = "shutdown now";
    # }
  ];

  debug = {
    persistJournalLogs = true;
    doVerboseKernelLogs = true;
  };
}

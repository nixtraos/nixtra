{ config, pkgs, ... }:

{
  hardware = {
    cpu = "intel";
    gpu = "nvidia";
  };

  disk = {
    partitions = {
      boot = "/dev/disk/by-label/boot";
      storage = "/dev/disk/by-uuid/1ee27263-3474-4a4a-b253-5712034dfec3";
    };

    encryption = {
      enable = true;
      decryptedRootDevice = "/dev/disk/by-uuid/3fdcc37a-0ba2-41bc-9bc5-b9f3160a0206";
    };
  };

  user = {
    terminal = "alacritty";
  };

  desktop = {
    startupPrograms = [
      "keepassxc"
      config.nixtra.user.terminal
      config.nixtra.user.browser
    ];
  };

  kernel = {
    type = "security";
    supportAll = true;
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

    vpn = {
      enable = true;
      type = "mullvad";
    };

    sops = {
      keys = {
        "password" = {
          neededForUsers = true;
        };
        "ssh/hosts/laptop/publicKey" = {
          neededForUsers = true;
        };
        "searx/secret" = {
          neededForUsers = true;
        };
        "miniflux/admin" = {
          format = "dotenv";
          sopsFile = ../../../secrets/miniflux.env;
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

  searx = {
    secretPath = "searx/secret";
  };

  syncthing = {
    enable = true;
  };

  ai = {
    comfyui = {
      enable = true;
    };
  };

  scheduledTasks = [
    # {
    #   enable = true;
    #   name = "system-shutdown";
    #   time = "23:00";
    #   action = "shutdown now";
    # }
  ];

  monitoring = {
    enable = false;
  };

  debug = {
    persistJournalLogs = true;
    doVerboseKernelLogs = true;
  };
}

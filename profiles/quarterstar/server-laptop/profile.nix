# Everything defined here is added to `config.nixtra`.
# See configuration documentation for more information.
# This configuration is specific to the machine of the
# person whose repository you obtained it from. You
# should make your own profile from scratch for your
# own machine.

{ config, pkgs, ... }:

{
  hardware = {
    laptop = true;
    cpu = "amd";
    gpu = "amd";
  };

  kernel = {
    enableNonfreeFirmware = true;
    extraPackages = [ config.boot.kernelPackages.rtl88x2bu ];
  };

  system = {
    filesystem = "ext4";
  };

  disk = {
    partitions = {
      boot = "/dev/disk/by-label/boot";
      storage = "/dev/disk/by-label/nixos";
    };

    encryption = {
      enable = false;
    };
  };

  ssh = {
    enable = true;
    permitRootLogin = true;
    userAuthorizedKeySecrets = [
      "ssh/hosts/laptop/authorizedKeys/pcuser"
    ];
    rootAuthorizedKeySecrets = [
      "ssh/hosts/laptop/authorizedKeys/pcroot"
    ];
  };

  user = {
    declarativeUsers.enable = false;
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

    sops = {
      keys = {
        "ssh/hosts/laptop/authorizedKeys/pcroot" = {
          neededForUsers = true;
        };
        "ssh/hosts/laptop/authorizedKeys/pcuser" = {
          neededForUsers = true;
        };
      };
    };
  };
}

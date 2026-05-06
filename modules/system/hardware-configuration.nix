{
  profileSettings,
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  hardware = lib.mkMerge [
    {
      enableAllFirmware = config.nixtra.kernel.supportAll;
      enableAllHardware = config.nixtra.kernel.supportAll;
    }

    (lib.mkIf config.nixtra.kernel.enableNonfreeFirmware {
      firmware = [ pkgs.linux-firmware ];
      enableRedistributableFirmware = true;
    })
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelPackages = lib.mkMerge [
    (lib.mkIf (config.nixtra.kernel.type == "custom") config.nixtra.kernel.customKernel)
    (lib.mkIf (config.nixtra.kernel.type == "security") pkgs.linuxKernel.packages.linux_hardened)
    (lib.mkIf (config.nixtra.kernel.type == "gaming") pkgs.linuxKernel.packages.linux_zen)
  ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = config.nixtra.kernel.extraPackages;
  boot.initrd.supportedFilesystems = config.nixtra.system.supportedFilesystems;

  # Fix bwrap exec error on Flatpak
  boot.kernel.sysctl = {
    "kernel.unprivileged_userns_clone" = 1;
  };

  # Full Disk Encryption
  boot.initrd.luks =
    if config.nixtra.disk.encryption.enable then
      {
        devices.cryptroot = {
          device = config.nixtra.disk.partitions.storage;
          allowDiscards = true;
          preLVM = true;
        };
      }
    else
      { };

  fileSystems."/" = {
    device =
      if config.nixtra.disk.encryption.enable then
        config.nixtra.disk.encryption.decryptedRootDevice
      else
        config.nixtra.disk.partitions.storage;

    fsType = config.nixtra.system.filesystem;
  };

  fileSystems."/boot" = {
    device = config.nixtra.disk.partitions.boot;
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.docker0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp24s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.virbr1.useDHCP = lib.mkDefault true;
  # networking.interfaces.virbr2.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = profileSettings.arch;
}

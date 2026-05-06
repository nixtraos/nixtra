# This is a rescue configuration for Nixtra - not the actual configuration.nix!
# To view the actual entrypoint, go to /etc/nixos/modules/system/configuration.nix

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixtra";
  networking.networkmanager.enable = true;

  users.users.rescue = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      tree
    ];
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
  ];

  system.stateVersion = "24.11";
}

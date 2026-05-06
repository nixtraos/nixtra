{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./samba.nix
    ./manager.nix
  ];

  config = lib.mkIf config.nixtra.security.virtualization {
    environment.systemPackages = with pkgs; [ virtiofsd ];

    # Enable virtualization
    virtualisation.libvirtd = {
      enable = true;
      qemu.vhostUserPackages = with pkgs; [ virtiofsd ]; # Allow shared filesystems between host and guest
    };

    # Clipboard sharing
    services.spice-vdagentd.enable = true;

    security.virtualisation.flushL1DataCache = "always";
  };
}

{ config, ... }:

{
  imports = [
    # Kernel
    ./boot.nix
    ./kernel.nix

    # NixOS
    ./update.nix
    ./gc.nix
    ./firewall.nix
    #./impermanence.nix

    # Core
    ./systemd.nix
    ./pam.nix
    ./permissions.nix
    #./services.nix
    ./dbus.nix
    ./audit.nix
    ./close-on-suspend.nix
    ./suid.nix
    ./fhs.nix

    # Applications
    ./doas.nix
    ./uutils.nix

    # Physical Protection
    ./usb.nix

    # Authentication
    ./fail2ban.nix
    ./sops.nix

    # Networking
    ./dns.nix
    ./vpn.nix

    # Cryptography
    #./entropy.nix

    # Sandboxing
    ./firejail/firejail.nix
    ./apparmor/apparmor.nix

    # SIEM
    #./zeek.nix
    #./wazuh.nix
    #./graylog.nix
    #./suricata.nix
  ];
}

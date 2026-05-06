{ inputs, config, ... }:

let
  modulesPath = "${inputs.nixpkgs}/nixos/modules";
in
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
    ./hyperfagia.nix
    ./systemd.nix
    ./pam.nix
    ./permissions.nix
    #./services.nix
    ./dbus.nix
    ./audit.nix
    ./close-on-suspend.nix
    ./suid.nix
    ./fhs.nix

    # FIXME: https://github.com/NixOS/nixpkgs/issues/360616
    #"${modulesPath}/profiles/hardened.nix" # NixOS security hardening
    # FIXME: recursion error in latest
    #"${inputs.nix-mineral}/nix-mineral.nix" # Complementary defaults for hardening for ones missed by security.nix and hardened.nix

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

{ config, ... }:

{
  # Restrict usage of Nix daemon and Nix package manager
  nix.settings.allowed-users = [
    "root"
    "@wheel"
  ];

  systemd.tmpfiles.rules = [ "d /etc/nixos 0700 root root - -" ];
}

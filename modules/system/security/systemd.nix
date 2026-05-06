{
  config,
  pkgs,
  lib,
  ...
}:

let
  liberatedSystemd = pkgs.systemd.overrideAttrs (old: {
    version = "259"; # target version listed in meson.version
    src = builtins.fetchGit {
      url = "https://codeberg.org/Jeffrey-Sardina/systemd";
      name = "systemd";
      rev = "9ca433482f2281d71718718705ca8cd3bf562ad6";
    };
  });
in
{
  # Replace systemd with libera-systemd (remove age verification)
  # systemd.package =
  #   lib.mkIf config.nixtra.security.aggressivelyRemoveVerificationMeasures
  #   liberatedSystemd;

  services.dbus.implementation = "broker";
  # FIXME
  #services.logrotate.enable = true;
  services.logrotate.checkConfig = false;

  # disable coredump that could be exploited later
  # and also slow down the system when something crash
  systemd.coredump.enable = false;

  services.journald = {
    storage = if config.nixtra.debug.persistJournalLogs then "persistent" else "volatile";
    upload.enable = false; # Disable remote log upload (the default)
    extraConfig = ''
      SystemMaxUse=500M
      SystemMaxFileSize=50M
    '';
  };

  # Restrict log access to root
  security.pam.services.systemd-journal.requireWheel = true;

  # Spoof machine ID for services
  environment.etc."machine-id" = lib.mkIf config.nixtra.anonymity.spoofMiscIdentifiers {
    text = "00000000000000000000000000000000";
  };

  users.groups.netdev = { };
}

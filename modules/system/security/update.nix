{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  config = lib.mkIf config.nixtra.security.autoUpdate {
    system.autoUpgrade = {
      enable = true;
      flake = inputs.self.outPath;
      flags = [
        "--update-input"
        "nixpkgs"
        "--update-input"
        "nixpkgs-unstable"
        "--update-input"
        "home-manager"
        "-L" # Print build logs
      ];
      dates = "daily";
      randomizedDelaySec = "45min";
      operation = "switch";
      allowReboot = false;
    };

    environment.systemPackages = with pkgs; lib.mkIf config.nixtra.desktop.enable [ libnotify ];

    systemd.services."nixos-upgrade" = lib.mkIf config.nixtra.desktop.enable {
      serviceConfig.ExecStopPost =
        let
          uid = builtins.toString config.nixtra.user.uid;
        in
        pkgs.writeShellScript "nixos-upgrade-post-hook" ''
          # $SERVICE_RESULT is a systemd variable indicating how the unit exited
          if [ "$SERVICE_RESULT" = "success" ]; then
            ${pkgs.systemd}/bin/machinectl --uid=${uid} shell .host /run/current-system/sw/bin/systemctl --user start nixos-upgrade-notification.service
          else
            ${pkgs.systemd}/bin/machinectl --uid=${uid} shell .host /run/current-system/sw/bin/systemctl --user start nixos-upgrade-notification@failure.service
          fi
        '';
    };

    systemd.user.services = {
      "nixos-upgrade-notification" = {
        description = "Notify user of successful upgrade";
        serviceConfig = {
          ExecStart = "${pkgs.libnotify}/bin/notify-send 'System Update Completed' 'An automatic system update has been completed successfully.'";
          Type = "oneshot";
        };
      };
      "nixos-upgrade-notification@" = {
        description = "Notify user of failed upgrade";
        serviceConfig = {
          ExecStart = "${pkgs.libnotify}/bin/notify-send -u critical 'System Update Failed' 'The automatic system update failed. Check journalctl -u nixos-upgrade.service'";
          Type = "oneshot";
        };
      };
    };
  };
}

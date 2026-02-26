{ config, lib, pkgs, ... }:

let
  inherit (config.nixtra.user) username;
  uid = builtins.toString config.nixtra.user.uid;

  notifScriptInit = pkgs.writeShellScriptBin "smartd-notify-init.sh" ''
    instance=$(printf '%s-%s' "$SMARTD_DEVICESTRING" "$SMARTD_MESSAGE" | sed 's/[^A-Za-z0-9._:-]/_/g')
    systemctl start --user smartd-notify@$instance.service
  '';

  notifScript = pkgs.writeShellScriptBin "smartd-notify.sh" ''
    instance="$1"

    SMARTD_DEVICESTRING=$(printf '%s' "$instance" | cut -d'-' -f1)
    SMARTD_MESSAGE=$(printf '%s' "$instance" | cut -d'-' -f2-)

    echo "SMARTD_DEVICESTRING: $SMARTD_DEVICESTRING"
    echo "SMARTD_MESSAGE: $SMARTD_MESSAGE"

    export XDG_RUNTIME_DIR="/run/user/${
      builtins.toString config.nixtra.user.uid
    }"
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${
      builtins.toString config.nixtra.user.uid
    }/bus"

    #USERNAME="${username}" UID="${uid}" runuser -u ${username} -- ${pkgs.libnotify}/bin/notify-send -u critical "$SMARTD_DEVICESTRING" "$SMARTD_MESSAGE"
  '';

  cfg = config.nixtra.disk;
  disks = [ cfg.partitions.boot cfg.partitions.storage ];
in {
  config = lib.mkIf config.nixtra.performance.monitorDeviceHealth {
    systemd.user.services."smartd-notify@.service" = {
      enable = true;
      serviceConfig = {
        Type = "oneshot";
        ExecStart = ''${notifScript}/bin/smartd-notify.sh "%i"'';
      };
    };

    services.smartd = {
      enable = true;
      notifications.test = true;
      autodetect = true;
      devices = (map (device: {
        inherit device;
        options =
          "-m <nomailer> -M exec ${notifScriptInit}/bin/smartd-notify-init.sh";
      }) disks);
    };
  };
}

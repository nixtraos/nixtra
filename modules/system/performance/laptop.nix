{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.nixtra.hardware.laptop {
    services.tlp = {
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0 = "20";
        STOP_CHARGE_THRESH_BAT0 = "80";
        #CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        USB_AUTOSUSPEND = "1";
        #USB_BLACKALIST = [] # put usb ids of your mice and keyboards here (if any)
        RUNTIME_PM_ON_BAT = "auto";
      };
    };

    powerManagement.cpuFreqGovernor = "schedutil";

    services.upower.enable = true;

    networking.networkmanager.wifi.powersave = true;

    systemd.services.powertop-autotune = {
      description = "Run powertop for power optimization";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.powertop}/bin/powertop --auto-tune";
      };
    };
  };
}

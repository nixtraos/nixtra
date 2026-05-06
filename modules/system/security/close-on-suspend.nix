{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf config.nixtra.security.closeOnSuspend.enable {
    systemd.services."close-on-suspend" = {
      enable = true;
      script = "${pkgs.writeShellScript "close-on-suspend.sh" ''
        #!/usr/bin/env bash

        # List of applications to kill
        APPS=(${lib.strings.concatStringsSep " " config.nixtra.security.closeOnSuspend.applications})

        # Kill each application
        for app in "''${APPS[@]}"; do
          pkill "$app"
        done

        echo "Applications killed before suspend."
      ''}";
      wantedBy = [ "sleep.target" ];
      before = [ "sleep.target" ];
      path = with pkgs; [ procps ];
    };
  };
}

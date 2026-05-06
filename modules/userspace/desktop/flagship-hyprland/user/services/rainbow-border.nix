{
  config,
  lib,
  pkgs,
  ...
}:

{
  config =
    lib.mkIf
      (
        config.nixtra.user.desktop == "flagship-hyprland"
        && (
          config.nixtra.desktop.flagship-hyprland.rainbowBorder
          || config.nixtra.desktop.flagship-hyprland.rainbowShadow
        )
      )
      {
        systemd.user.services."rainbow-border" = {
          Unit = {
            Description = "Rainbow border animation for Hyprland";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            ExecStart = "${pkgs.writeShellScript "rainbow-border.sh" ''
              #!/usr/bin/env bash

              export PATH=${pkgs.hyprland}/bin:$PATH

              # Define the rainbow colors in correct Hyprland format
              colors=(
                  "rgba(ff0000ff)"  # Red
                  "rgba(ff7f00ff)"  # Orange
                  "rgba(ffff00ff)"  # Yellow
                  "rgba(00ff00ff)"  # Green
                  "rgba(00ffffff)"  # Cyan
                  "rgba(0000ffff)"  # Blue
                  "rgba(8b00ffff)"  # Purple
              )

              # Get original border setting to restore on exit
              original_border=$(hyprctl getoption general:col.active_border | awk -F'"' '/str:/ {print $2}')
              original_shadow=$(hyprctl getoption decoration:shadow:color | awk -F'"' '/str:/ {print $2}')

              # Cleanup function to restore original border
              cleanup() {
                  hyprctl keyword general:col.active_border "$original_border" > /dev/null
                  hyprctl keyword decoration:shadow:color "$original_shadow" > /dev/null
                  exit 0
              }
              trap cleanup SIGINT SIGTERM

              # Main animation loop
              while true; do
                  # Rotate colors array
                  first_color="''${colors[0]}"
                  new_colors=("''${colors[@]:1}")
                  colors=("''${new_colors[@]}" "$first_color")

                  # Build gradient string
                  gradient=""
                  for color in "''${colors[@]}"; do
                      gradient+="$color "
                  done
                  gradient+="45deg"

                  # Apply to Hyprland
                  ${
                    if config.nixtra.desktop.flagship-hyprland.rainbowBorder then
                      ''
                        hyprctl keyword general:col.active_border "$gradient" > /dev/null
                      ''
                    else
                      ""
                  }

                  ${
                    if config.nixtra.desktop.flagship-hyprland.rainbowShadow then
                      ''
                        hyprctl keyword decoration:shadow:color "''${colors[0]}" > /dev/null
                      ''
                    else
                      ""
                  }

                  # Control animation speed (adjust as needed)
                  sleep 0.2
              done
            ''}";
            Restart = "on-failure";
            RestartSec = 1;
          };
          Install = {
            WantedBy = [ ];
          };
        };
      };
}

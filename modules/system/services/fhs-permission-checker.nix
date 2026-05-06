{ ... }:

{
  systemd.services.fhs-permission-checker = {
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      set -euo pipefail

      declare -A paths=(
        ["/"]="root:root"
        ["/run"]="root:root"
        ["/var"]="root:root"
        ["/nix"]="root:nixbld"
        ["/dev"]="root:root"
      )

      for path in "''${!paths[@]}"; do
        expected_owner="''${paths[$path]}"
        actual_owner="$(stat -c '%U:%G' "$path")"

        if [[ "$actual_owner" != "$expected_owner" ]]; then
          echo "Permission mismatch at $path: expected $expected_owner, got $actual_owner"

          if [[ "$EUID" -eq 0 ]]; then
            echo "Fixing ownership of $path..."
            chown "$expected_owner" "$path"
          else
            echo "Skipping fix, not running as root."
          fi
        fi
      done
    '';
    wantedBy = [ "multi-user.target" ];
  };

  systemd.timers.fhs-permission-checker = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "1d";
      Persistent = true;
    };
  };
}

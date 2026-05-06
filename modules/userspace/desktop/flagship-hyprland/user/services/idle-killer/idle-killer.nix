{
  config,
  lib,
  pkgs,
  nixtraLib,
  ...
}:

let
  inherit (nixtraLib.command) createCommand;
  idle-killer-concurrent-script = import ./idle-killer-concurrent.nix { inherit createCommand pkgs; };
  idle-killer-priority-script = import ./idle-killer-priority.nix { inherit createCommand pkgs; };
in
{
  config =
    lib.mkIf
      (
        config.nixtra.user.desktop == "flagship-hyprland"
        && config.nixtra.desktop.flagship-hyprland.idleKiller.enable
      )
      {
        systemd.user.services = {
          "idle-killer-concurrent" = {
            Unit = {
              Description = "Idle Killer (Concurrent per-app timers)";
              After = "graphical-session.target";
            };

            Service = {
              Type = "simple";
              ExecStart = "${idle-killer-concurrent-script}/bin/idle-killer-concurrent";
              Restart = "on-failure";
              RestartSec = "5";
            };

            Install = {
              WantedBy = [ "default.target" ];
            };
          };

          "idle-killer-priority" = {
            Unit = {
              Description = "Idle Killer (Priority / oldest-app timer)";
              After = "graphical-session.target";
            };

            Service = {
              Type = "simple";
              ExecStart = "${idle-killer-priority-script}/bin/idle-killer-priority";
              Restart = "on-failure";
              RestartSec = "5";
            };

            Install = {
              WantedBy = [ "default.target" ];
            };
          };
        };

        xdg.configFile."idle-killer/config" = {
          text = ''
            POLL_INTERVAL=${builtins.toString config.nixtra.desktop.flagship-hyprland.idleKiller.pollInterval}
            DEFAULT_TIMEOUT=${builtins.toString config.nixtra.desktop.flagship-hyprland.idleKiller.defaultTimeout}

            # Per-app timeouts (seconds). Keys are window "class" as reported by hyprctl.
            # Example: APP_TIMEOUTS=(["Firefox"]=900 ["Slack"]=1800)
            declare -A APP_TIMEOUTS
            APP_TIMEOUTS=( 
              ${lib.concatStringsSep "\n" (
                map (
                  app: ''["${app.class}"]=${builtins.toString app.timeout}''
                ) config.nixtra.desktop.flagship-hyprland.idleKiller.appTimeouts
              )}
            )

            # List of managed app class-names (space separated). If empty, all apps found in APP_TIMEOUTS are managed.
            MANAGED_APPS="${
              lib.concatStringsSep " " (
                map (app: app.class) config.nixtra.desktop.flagship-hyprland.idleKiller.appTimeouts
              )
            }"

            # Behavior:
            # - If MANAGED_APPS is empty/blank, the services manage every app that appears in APP_TIMEOUTS.
            # - If MANAGED_APPS contains items, only those are managed.
            # - If an app is found but not listed in APP_TIMEOUTS, DEFAULT_TIMEOUT is used.

            # Path prefix for optional hooks: check for "unfinished work"
            # Hook naming convention (executable):
            #   /usr/local/bin/idle-killer-check-<app-class>
            # hook should exit with:
            #   0  => *has unfinished work* (skip kill)
            #   1  => *no unfinished work* (OK to kill)
            # TODO
            UNFINISHED_HOOK_PREFIX="~/.config/idle-killer"
            KILL_METHOD="${config.nixtra.desktop.flagship-hyprland.idleKiller.killMethod}"
            LOGTAG="idle-killer"
            KILL_GRACE=${builtins.toString config.nixtra.desktop.flagship-hyprland.idleKiller.killGrace}
            HYPRCTL_BATCH=${
              if config.nixtra.desktop.flagship-hyprland.idleKiller.hyprctlBatch then "true" else "false"
            }
          '';
        };
      };
}

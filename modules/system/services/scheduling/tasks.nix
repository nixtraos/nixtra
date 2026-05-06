{
  config,
  pkgs,
  lib,
  ...
}:

let
  mkService = task: {
    name = task.name;
    value = {
      description = "Scheduled task: ${task.name}";
      script = task.action;
      serviceConfig.Type = "oneshot";
      startAt = task.time;
    };
  };
in
{
  systemd.services = builtins.listToAttrs (
    map mkService (
      builtins.filter (
        task: if (builtins.hasAttr "enabled" task) then task.enabled else true
      ) config.nixtra.scheduledTasks
    )
  );
}

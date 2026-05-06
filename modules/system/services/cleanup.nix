{ config, pkgs, ... }:

let
  userConfig = config.users.users.${config.nixtra.user.username};
in
{
  systemd.services.user-cache-cleanup = {
    description = "Clean user cache directory on shutdown";
    after = [ "multi-user.target" ];
    before = [ "shutdown.target" ];
    wantedBy = [ "shutdown.target" ];
    script = ''
      echo "Cleaning cache for user ${config.nixtra.user.username}..."
      rm -rf ${userConfig.home}/.cache
    '';
    serviceConfig = {
      User = userConfig.uid;
      Group = userConfig.gid;
    };
  };
}

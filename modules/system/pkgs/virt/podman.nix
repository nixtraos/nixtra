{ config, ... }:

{
  virtualisation.podman = {
    enable = true;
    # dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # for rootless mode
  users.users.${config.nixtra.user.username} = {
    subUidRanges = [
      {
        startUid = 100000;
        count = 65536;
      }
    ];
    subGidRanges = [
      {
        startGid = 100000;
        count = 65536;
      }
    ];
  };
}

{ config, ... }:

{
  # For shared directories on Windows guests
  services.samba.enable = true;
  services.samba.settings = {
    shared = {
      path = "/home/${config.nixtra.user.username}/Volumes/win11-re";
      browseable = "yes";
      "read only" = "no";
    };
  };
}

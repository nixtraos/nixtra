{
  settings,
  profileSettings,
  config,
  ...
}:

{
  imports = [
    # Profile-based configuration
    ../../../profiles/${settings.profile}/homes/root.nix
    ../../../presets/${profileSettings.preset}/homes/root.nix

    ./common.nix
    ../desktop/root/prelude.nix
  ];

  config = {
    home.username = "root";
    home.homeDirectory = "/root";
    home.stateVersion = config.nixtra.system.version;
  };
}

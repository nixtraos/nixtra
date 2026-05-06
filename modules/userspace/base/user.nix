{
  settings,
  profileSettings,
  lib,
  pkgs,
  nixtraLib,
  config,
  # osConfig, # Allows HM to read top-level NixOS module `config`
  ...
}:

{
  imports = [
    # Profile-based configuration
    ../../../profiles/${settings.profile}/homes/user.nix
    ../../../presets/${profileSettings.preset}/homes/user.nix

    ./common.nix
    ../desktop/user/prelude.nix
    ../theme/type.nix
    ../theme/applications.nix

    # Out of order
    #../sources/flatpak.nix
  ];

  config = {
    xdg.configFile."mimeapps.list".force = true;

    home.sessionVariables = {
      BROWSER = config.nixtra.user.browser;
      DEFAULT_BROWSER = config.nixtra.user.browser;
    };

    home.username = config.nixtra.user.username;
    home.homeDirectory = "/home/${config.nixtra.user.username}";
    home.stateVersion = config.nixtra.system.version;
  };
}

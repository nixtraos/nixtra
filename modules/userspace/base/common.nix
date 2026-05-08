{
  osConfig,
  nixtraLib,
  lib,
  config,
  pkgs,
  ...
}:

{
  imports = [
    ../pkgs/terminal/terminal.nix
    ../pkgs/shell/shell.nix
    ../config/prelude.nix
  ];

  config = {
    home.sessionVariables = {
      EDITOR = config.nixtra.user.editor;
      TERMINAL = config.nixtra.user.terminal;
    }
    // config.nixtra.shell.environmentVariables;

    home.packages = with pkgs; [
      dconf
    ];

    systemd.user.sessionVariables = config.nixtra.shell.environmentVariables;

    # Enable automatic management of directories specified in the XDG specification
    # https://xdgbasedirectoryspecification.com/
    xdg = {
      enable = true;
      userDirs.enable = true;
    };

    # Fix https://github.com/nix-community/home-manager/issues/1213
    #xdg.configFile."mimeapps.list".force = true;

    xdg.portal = {
      enable = true;
      #extraPortals = with pkgs;
      #[
      #kdePackages.xdg-desktop-portal-kde
      #xdg-desktop-portal-gtk
      #];

      config = {
        # Fix Portal v1.17+ incompatibility
        common.default = "*";

        #"org.freedesktop.impl.portal.FileChooser" = { default = "kde"; };
      };
    };
  };
}

{ config, lib, pkgs, ... }:

let
  graphicalSessionVariables =
    "{ PATH, USER, HOME, SHELL, DISPLAY, XAUTHORITY, WAYLAND_DISPLAY, XDG_RUNTIME_DIR, DBUS_SESSION_BUS_ADDRESS, GDK_BACKEND, QT_QPA_PLATFORM, QT_AUTO_SCREEN_SCALE_FACTOR, QT_SCALE_FACTOR, QT_SCREEN_SCALE_FACTORS, MOZ_ENABLE_WAYLAND, MOZ_DBUS_REMOTE }";
in {
  config = lib.mkIf config.nixtra.security.replaceSudoWithDoas {
    security.doas = {
      enable = true;
      extraConfig = ''
        permit persist :wheel
        permit persist setenv ${graphicalSessionVariables} :wheel as root cmd /run/current-system/sw/bin/cat
        permit persist setenv ${graphicalSessionVariables} :wheel as root cmd /run/current-system/sw/bin/wl-copy
      '';

      # Permit specific commands for user
      #extraConfig = ''
      #  permit nopass keepenv user foo cmd /run/current-system/sw/bin/cat
      #'';
    };

    security.doas.extraRules = [
      {
        users = [ "${config.nixtra.user.username}" ];
        keepEnv = true;
        persist = true;
      }
      {
        users = [ "${config.nixtra.user.username}" ];
        cmd = "tee";
        noPass = true;
      }
    ];

    environment.systemPackages =
      [ (pkgs.writeScriptBin "sudo" ''exec doas "$@"'') ];

    security.sudo.enable = lib.mkForce false;
  };
}

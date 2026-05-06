# https://github.com/AaronVerDow/nix/blob/main/common/apparmor/README.md

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.nixtra.security.apparmor;
in
{
  imports = [
    ./apparmor_d_module.nix
    ./commands/commands.nix
  ];

  config = lib.mkIf cfg.enable {
    nixpkgs = {
      overlays = [
        (final: prev: {
          apparmor-d = final.callPackage ./apparmor-d_package.nix { };
        })
      ];
    };

    security.apparmor.enable = true;

    # Add additional profiles using apparmor_d module
    security.apparmor_d = {
      enable = true;
      profiles = {
        "firefox.apparmor.d" = "enforce";
        vlc = "enforce";
        dmesg = "enforce";
        btop = "enforce";
      };
    };

    # Add boot entry with AppArmor disabled in case of lockout
    # STRONGLY recommended
    specialisation = lib.mkIf cfg.rescueBootEntry {
      no-apparmor = {
        configuration = {
          security.apparmor.enable = lib.mkForce false;
        };
      };
    };

    # Other recommended settings, may be optional:

    # Adds aa-log, which is useful for debugging
    # May do other things in this context I'm not aware of
    environment.systemPackages = with pkgs; [ apparmor-parser ];

    # Kill existing processes if they can be confined
    security.apparmor.killUnconfinedConfinables = false;

    services.dbus.apparmor = "enabled";
    security.apparmor.enableCache = true;
  };
}

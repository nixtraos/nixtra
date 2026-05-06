# reflection.nix
#
# "Metaconfiguration" that gets added by Nixtra code itself
# to your configuration. This is mostly used for hacky/temporary
# fixes, such as for fixing the environment variable used by SSH
# for askpass.
# It's called reflection because Nixtra code can essentially reflect
# on itself and use its own interface that it provides to the user to
# make its own work easier; a metaphor to real reflection systems
# in programming languages.
# This is needed because any Nixtra configuration set by an import of
# configuration.nix will be overwritten by the user configuration.
#
# Reflection happens after the following processes finish:
# preset integration, profile integration

{
  pkgs,
  lib,
  nixtra,
  ...
}:

{
  sudo.environmentVariablesToRetainForShell =
    # General display environment
    (
      if nixtra.display.enable then
        [
          "DISPLAY"
          "DBUS_SESSION_BUS_ADDRESS"
        ]
      else
        [ ]
    )
    ++
      # Environment variables that might be required for xorg
      (if nixtra.display.enable && nixtra.display.server == "xorg" then [ "XAUTHORITY" ] else [ ])
    ++
      # Environment variables required for allowing root user to copy text to system clipboard with backends like wl-copy.
      (
        if nixtra.display.enable && nixtra.display.server == "wayland" then
          [
            "XDG_RUNTIME_DIR"
            "WAYLAND_DISPLAY"
          ]
        else
          [ ]
      );
}

{ lib, config, ... }:

let
  version = config.nixtra.system.version;
  parts = builtins.splitVersion version;
  major = lib.toIntBase10 (builtins.elemAt parts 0);
  minor = lib.toIntBase10 (builtins.elemAt parts 1);
in {
  # https://github.com/NixOS/nixpkgs/issues/465407
  config =
    lib.mkIf (major <= 25 && minor <= 5) { services.preload.enable = true; };
}

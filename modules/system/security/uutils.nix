{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.nixtra.security.replaceCoreutilsWithUutils {
    environment.systemPackages = with pkgs; [ uutils-coreutils-noprefix ];
  };
}

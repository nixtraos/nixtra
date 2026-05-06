{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.nixtra.flatpak.enable {
    services.flatpak = {
      enable = true;
      #packages = [ ];
      #uninstallUnmanaged = true;
      #update.auto.enable = false;
    };

    security.wrappers."bwrap" = {
      owner = "root";
      group = "root";
      source = "${pkgs.bubblewrap}/bin/bwrap";
      setuid = true;
    };
  };
}

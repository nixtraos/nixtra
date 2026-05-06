{
  config,
  lib,
  nixtraLib,
  pkgs,
  ...
}:

let
  cfg = config.nixtra.security.firejail;
in
{
  config = lib.mkIf cfg.enable {
    environment.etc =
      let
        myEtcDir = ./profiles;
        etcFiles = builtins.readDir myEtcDir;
        generatedEtc = lib.mapAttrs' (name: type: {
          inherit name;
          value.source = "${myEtcDir}/${name}";
        }) (lib.filterAttrs (_: type: type == "regular") etcFiles);
      in
      builtins.mapAttrs (name: value: { source = value.source; }) (
        lib.mapAttrs' (name: value: {
          name = "firejail/${name}"; # Prefix inside /etc
          value = value;
        }) generatedEtc
      );

    environment.systemPackages = [
      (nixtraLib.sandbox.wrapFirejail {
        executable = "${pkgs.iputils}/bin/ping";
        profile = "ping";
      })

      # required for dbus-user filters
      pkgs.xdg-dbus-proxy
    ];

    programs.firejail.enable = true;
  };
}

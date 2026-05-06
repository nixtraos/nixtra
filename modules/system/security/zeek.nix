{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [ inputs.zeek-nix.nixosModules.zeek ];

  config = lib.mkIf config.nixtra.security.siem.zeek.enable {
    services.zeek = {
      enable = true;
      standalone = true;
      interface = config.nixtra.security.siem.zeek.interface;
      host = "localhost";
      package = pkgs.zeekWithPlugins {
        package = pkgs.zeek-latest;
        plugins = [ { src = pkgs.zeek-sources.zeek-community-id; } ];
      };

      privateScripts = ''
        @load /home/gtrun/project/hardenedlinux-zeek-script/scripts/zeek-query.zeek
        @load /home/gtrun/project/hardenedlinux-zeek-script/scripts/log-passwords.zeek
      '';
    };
  };
}

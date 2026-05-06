{ lib, config, ... }:

{
  config = lib.mkIf config.nixtra.i2p.enable {
    services.i2pd = {
      enable = true;
      address = "127.0.0.1";
      proto = {
        http.enable = true;
        socksProxy.enable = true;
        httpProxy.enable = true;
        sam.enable = true;
        i2cp = {
          enable = true; # I2P torrenting
          address = "127.0.0.1";
          port = 7656;
        };
      };
    };
  };
}

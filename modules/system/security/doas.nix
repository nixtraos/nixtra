{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.nixtra.security.replaceSudoWithDoas {
    security.doas = {
      enable = true;
    };

    security.doas.extraRules = [
      #
      {
        groups = [ "wheel" ];
        persist = false;
        setEnv = config.nixtra.sudo.environmentVariablesToRetainForShell;
        keepEnv = false;
      }
      # {
      #   groups = [ "wheel" ];
      #   cmd = "/run/wrappers/bin/su";
      #   setEnv = config.nixtra.sudo.environmentVariablesToRetainForShell;
      #   persist = false;
      # }
    ];

    environment.systemPackages = [ (pkgs.writeScriptBin "sudo" ''exec doas "$@"'') ];

    security.sudo.enable = lib.mkForce false;
  };
}

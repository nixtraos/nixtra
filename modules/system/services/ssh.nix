{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.nixtra.ssh.enable {
    programs.ssh = lib.mkDefault {
      startAgent = true;
      knownHosts = lib.mkMerge (builtins.mapAttrs (name: value: {
        ${name} = {
          inherit (value) hostNames;
          publicKeyFile = config.sops.secrets."${value.publicKeySecret}".path;
        };
      }));
    };

    services.openssh = {
      enable = true;
      ports = [ 22 ];
      settings = {
        PasswordAuthentication = "no";
        KbdInteractiveAuthentication = false;
        PermitRootLogin =
          if config.nixtra.ssh.permitRootLogin then "yes" else "no";
        AllowUsers = [ config.nixtra.user.userName "myUser" ];
      };
    };

    # SSH tarpit that slows down malicious or automated SSH connection attempts by indefinitely delaying connections
    services.endlessh = {
      enable = true;
      port = 22;
      openFirewall = true;
    };

    users.users.root.openssh.authorizedKeys.keyFiles =
      map (secret: config.sops.secrets."${secret}".path)
      config.nixtra.ssh.rootAuthorizedKeySecrets;
    users.users.${config.nixtra.user.username}.openssh.authorizedKeys.keyFiles =
      map (secret: config.sops.secrets."${secret}".path)
      config.nixtra.ssh.userAuthorizedKeySecrets;
  };
}

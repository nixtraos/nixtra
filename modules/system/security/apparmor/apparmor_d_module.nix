{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkIf
    mapAttrs
    assertMsg
    pathIsRegularFile
    mkEnableOption
    mkOption
    types
    ;

  cfg = config.security.apparmor_d;
  inherit (pkgs) apparmor-d;
in
{
  options.security.apparmor_d = with lib; {
    enable = mkEnableOption "enable apparmor.d support";

    profiles = mkOption {
      type = types.attrsOf (
        types.enum [
          "disable"
          "complain"
          "enforce"
        ]
      );
      default = { };
      description = "set of apparmor profiles to include from apparmor.d";
    };
  };

  config = mkIf (cfg.enable) {
    security.apparmor.packages = [ apparmor-d ];
    security.apparmor.policies = mapAttrs (name: state: {
      inherit state;
      path =
        let
          file = "${apparmor-d}/etc/apparmor.d/${name}";
        in
        assert assertMsg (pathIsRegularFile file) "profile ${name} not found in apparmor.d path (${file})";
        file;
    }) cfg.profiles;

    security.apparmor.includes."tunables/global.d/store" = ''
      @{package1}={@{w},.,-}
      @{package2}=@{package1}@{package1}
      @{package4}=@{package2}@{package2}
      @{package8}=@{package4}@{package4}
      @{package16}=@{package8}@{package8}
      @{package32}=@{package16}@{package16}
      @{package64}=@{package32}@{package32}

      @{nix_package_name}={@{package32},}{@{package16},}{@{package8},}{@{package4},}{@{package2},}{@{package1},}
      @{nix_store}=/nix/store/@{rand32}-@{nix_package_name}
    '';

    environment.systemPackages = [ apparmor-d ];
  };
}

{ inputs, config, pkgs, ... }:

{
  imports = [
    ./untracked.nix

    # Bundles
    ../../modules/system/bundles/gaming.nix
    ../../modules/system/bundles/programming.nix

    # Programs & Packages

    # Services
    ../../modules/system/services/opensnitch.nix
  ];

  services.protonmail-bridge.enable = true;

  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;

  security.chromiumSuidSandbox.enable = true;
}

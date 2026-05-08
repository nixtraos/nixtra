{
  lib,
  inputs,
  config,
  pkgs,
  ...
}:

{
  imports = [
    (import ../common/system/syncthing.nix {
      localMachine = "primary-laptop";
      inherit lib;
    })

    # Bundles
    ../../../modules/system/bundles/programming.nix

    # Programs & Packages

    # Services
  ];
}

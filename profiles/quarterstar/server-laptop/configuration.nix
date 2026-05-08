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
      localMachine = "server-laptop";
      inherit lib;
    })

    ../common/system/syncthing.nix

    # Bundles
    ../../../modules/system/bundles/programming.nix

    # Programs & Packages

    # Services
  ];
}

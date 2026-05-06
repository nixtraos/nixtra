{
  inputs,
  config,
  pkgs,
  ...
}:

{
  imports = [
    # Bundles
    ../../../modules/system/bundles/programming.nix

    # Programs & Packages

    # Services
  ];
}

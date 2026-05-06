# Special configuration for packages that need to be installed from the nixpkgs unstable channel.
# Should not be used for most of the packages.

{ config, lib, ... }:

{
  allowUnfreePredicate =
    pkg: builtins.elem (lib.getName pkg) config.nixtra.security.permittedUnfreePackages;
  permittedInsecurePackages =
    if !config.nixtra.security.networking then
      config.nixtra.security.permittedInsecurePackages
    else
      [ ];
}

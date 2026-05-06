{ lib, pkgs, ... }:
{
  mkNixtraOption =
    type: default: description:
    lib.mkOption { inherit type default description; };
}

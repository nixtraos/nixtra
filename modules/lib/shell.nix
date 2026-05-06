{ lib, ... }:

{
  nixListToBashList =
    list:
    let
      quoted = map lib.escapeShellArg list;
      joined = builtins.concatStringsSep " " quoted;
    in
    "(${joined})";

  nixListToBashBraceExpansion =
    list:
    let
      quoted = map lib.escapeShellArg list;
      joined = builtins.concatStringsSep "," quoted;
    in
    "{${joined}}";
}

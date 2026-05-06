{ pkgs, ... }:
{
  floatToInt =
    float:
    pkgs.runCommand "floatToInt" { } ''
      int=$(printf "%.f" "${float}
      echo "$TRUNCATED_VALUE" > $int
    '';
}

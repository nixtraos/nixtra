{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ cacert ];
}

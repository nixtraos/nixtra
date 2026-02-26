{ pkgs, ... }:

{
  home.packages = with pkgs; [ timeshift ];
}

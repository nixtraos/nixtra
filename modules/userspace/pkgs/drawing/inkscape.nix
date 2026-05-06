{
  config,
  pkgs,
  nixtraLib,
  ...
}:

{
  home.packages = with pkgs; [ inkscape ];
}

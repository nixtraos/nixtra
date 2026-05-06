{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.neovim.enable = lib.mkIf (!config.programs.nixvim.enable) true;
}

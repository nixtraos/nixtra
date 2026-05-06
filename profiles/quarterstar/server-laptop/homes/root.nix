{
  settings,
  profile,
  config,
  pkgs,
  ...
}:

{
  imports = [ ../../../../modules/userspace/pkgs/editor/neovim.nix ];

  programs.home-manager.enable = true;
}

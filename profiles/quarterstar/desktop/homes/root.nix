{ ... }:

{
  imports = [
    ../../../../modules/userspace/pkgs/editor/neovim.nix
    ../../common/userspace/cargo.nix
  ];

  programs.home-manager.enable = true;
}

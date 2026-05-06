{
  settings,
  profile,
  config,
  pkgs,
  ...
}:

{
  imports = [
    ../../../../modules/userspace/bundles/programming.nix
    ../../../../modules/userspace/bundles/mathematics.nix

    ../../../../modules/userspace/pkgs/video/mpv.nix
    ../../../../modules/userspace/pkgs/password/keepassxc.nix
    ../../../../modules/userspace/pkgs/drawing/gromit.nix
    ../../../../modules/userspace/pkgs/image/swayimg.nix

    ../../common/userspace/cargo.nix
  ];

  programs.home-manager.enable = true;
}

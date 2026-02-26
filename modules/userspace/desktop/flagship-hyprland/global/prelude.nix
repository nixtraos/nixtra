{ nixtraLib, config, pkgs, lib, ... }:

{
  imports = [
    ./programs/shell/zsh.nix
    ./programs/theme/qt.nix
    ./programs/theme/gtk.nix

    ./services/polkit.nix
    ./services/portal.nix

    ../../../pkgs/aesthetic/nwg-look.nix
  ];

  config = lib.mkIf (config.nixtra.user.desktop == "flagship-hyprland") {
    nixtra = { user = { shell.backend = lib.mkDefault "zsh"; }; };
  };
}

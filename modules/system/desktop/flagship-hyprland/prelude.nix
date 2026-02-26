{ config, lib, pkgs, ... }:

{
  imports = [
    ./options.nix
    ./programs/wm/hyprland.nix
    ./programs/login/sddm.nix
    ./programs/theme/gtk.nix
    ./programs/theme/qt.nix
    ./services/udev.nix
    ./services/polkit.nix
    ./services/udisks2.nix
    ./services/searxng.nix
  ];
}

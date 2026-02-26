{ config, lib, pkgs, ... }:

let
  tokyo-night-sddm =
    pkgs.libsForQt5.callPackage ../../packages/sddm-theme/default.nix { };
in {
  config = lib.mkIf (config.nixtra.user.desktop == "flagship-hyprland") {
    environment.systemPackages = with pkgs; [
      sddm-astronaut
      kdePackages.qtmultimedia
      #tokyo-night-sddm
    ];

    services.displayManager.sddm = {
      enable = true;
      theme = "sddm-astronaut-theme";
      #theme = "tokyo-night-sddm";
      settings.General.DisplayServer = "wayland";
    };
  };
}

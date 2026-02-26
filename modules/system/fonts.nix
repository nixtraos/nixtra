{ config, pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      # Packed fonts
      font-awesome

      # Common fonts
      #dejavu_fonts
      #roboto
      #liberation_ttf
      #open-sans
      #inter
      #overpass
      inter
      merriweather
      source-serif-pro

      # CJK fonts
      noto-fonts
      noto-fonts-color-emoji
      #noto-fonts-cjk-serif
      #noto-fonts-emoji
      #wqy_microhei
      #lxgw-wenkai
      #lxgw-neoxihei

      # Coding fonts
      nerd-fonts.jetbrains-mono
      #jetbrains-mono
      #roboto-mono
      #ibm-plex
      #camingo-code
      #victor-mono
      #iosevka
      #source-code-pro
      #cascadia-code
      #fira-code
    ];

    fontconfig = {
      enable = true;

      defaultFonts = {
        serif = [ "Source Serif 4" "Merriweather" ];
        sansSerif = [ "Inter" "Noto Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" "Fira Code" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}

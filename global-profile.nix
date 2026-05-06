{ config, pkgs, ... }:

{
  security = {
    hyperfagia = {
      spl =
        pkgs: with pkgs; [
          git
          okular
          mpv
          drawio
          krita
          libreoffice
        ];
    };
  };
}

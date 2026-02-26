{ nixtraLib, config, pkgs, lib, ... }:

{
  imports = [
    ../global/prelude.nix

    ./programs/terminal/kitty.nix
    ./programs/wm/hyprland/hypr.nix
    ./programs/wm/rofi.nix
    ./programs/wm/waybar/waybar.nix
    ./programs/wm/notif/mako.nix
    ./programs/music/cava.nix

    ./services/rainbow-border.nix
    ./services/switch-wallpaper.nix
    ./services/idle-killer/idle-killer.nix
    ./services/udiskie.nix

    ./commands/commands.nix

    ../../../pkgs/notif/mako.nix # Notification daemon
    ../../../pkgs/wayland/waypaper.nix # Wallpaper picker
    ../../../pkgs/drawing/wayscriber.nix # Screen annotator tool
  ];

  config.nixtra = {
    user = { browser = lib.mkDefault "librewolf"; };

    desktop = {
      startupPrograms = lib.mkDefault [
        config.nixtra.user.terminal
        config.nixtra.user.browser
      ];

      taskbar.apps = lib.mkDefault [
        {
          program = "${pkgs.kitty}/bin/kitty";
          icon = "terminal.png";
        }
        {
          program = "${pkgs.xfce.thunar}/bin/thunar";
          icon = "file-manager.png";
        }
        {
          program = "${pkgs.kitty}/bin/kitty ${pkgs.lunarvim}/bin/lunarvim";
          icon = "lunarvim.png";
        }
        {
          program = "${pkgs.librewolf}/bin/librewolf";
          icon = "librewolf.png";
        }
        {
          program = "${pkgs.freetube}/bin/freetube";
          icon = "freetube.png";
        }
        {
          program = "tor-browser-clearnet";
          icon = "tor-browser-clearnet.png";
        }
        {
          program = "tor-browser-proxy";
          icon = "tor-browser-proxy.png";
        }
        {
          program = "tor-browser";
          icon = "tor-browser.png";
        }
        {
          program = "${pkgs.kdePackages.okular}/bin/okular";
          icon = "okular.png";
        }
        {
          program = "${pkgs.virt-manager}/bin/virt-manager";
          icon = "vm.png";
        }
        {
          program = "${pkgs.openboard}/bin/OpenBoard";
          icon = "openboard.png";
        }
        {
          program = "${pkgs.krita}/bin/krita";
          icon = "krita.png";
        }
        {
          program = "${pkgs.keepassxc}/bin/keepassxc";
          icon = "keepassxc.png";
        }
      ];

      mimeapps = {
        "text/html" = [ "librewolf.desktop" ];
        "application/xhtml+xml" = [ "librewolf.desktop" ];
        "x-scheme-handler/http" = [ "librewolf.desktop" ];
        "x-scheme-handler/https" = [ "librewolf.desktop" ];
        "x-scheme-handler/ftp" = [ "librewolf.desktop" ];
        "x-scheme-handler/about" = [ "librewolf.desktop" ];
        "x-scheme-handler/unknown" = [ "librewolf.desktop" ];
        "video/x-matroska" = [ "mpv.desktop" ];
        "video/mp4" = [ "mpv.desktop" ];
        "video/webm" = [ "mpv.desktop" ];
        "video/mpeg" = [ "mpv.desktop" ];
        "video/quicktime" = [ "mpv.desktop" ];
        "image/jpeg" = [ "krita.desktop" ];
        "image/png" = [ "krita.desktop" ];
        "image/gif" = [ "krita.desktop" ];
        "image/tiff" = [ "krita.desktop" ];
        "image/bmp" = [ "krita.desktop" ];
        "image/webp" = [ "krita.desktop" ];
        "image/svg+xml" = [ "krita.desktop" ];
        "inode/directory" = [ "thunar.desktop" ];
        "application/pdf" = [ "okularApplication_pdf.desktop" ];
        "application/epub+zip" = [ "okularApplication_epub.desktop" ];
        "image/vnd.djvu" = [ "okularApplication_djvu.desktop" ];
        "image/x-djvu" = [ "okularApplication_djvu.desktop" ];
        "application/x-cbr" = [ "okularApplication_chm.desktop" ];
        "application/x-cbz" = [ "okularApplication_chm.desktop" ];
        "application/oxps" = [ "okularApplication_oxps.desktop" ];
        "application/vnd.ms-xpsdocument" = [ "okularApplication_xps.desktop" ];
        "application/x-mobipocket-ebook" = [ "okular.desktop" ];
        "application/x-mobipocket" = [ "okular.desktop" ];
        "application/x-chm" = [ "okularApplication_chm.desktop" ];
        "application/x-fictionbook+xml" = [ "okular.desktop" ];
        "application/vnd.oasis.opendocument.text" =
          [ "libreoffice-writer.desktop" ];
        "application/vnd.oasis.opendocument.spreadsheet" =
          [ "libreoffice-calc.desktop" ];
        "application/vnd.oasis.opendocument.presentation" =
          [ "libreoffice-impress.desktop" ];
        "application/msword" = [ "libreoffice-writer.desktop" ];
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
          [ "libreoffice-writer.desktop" ];
        "application/vnd.ms-excel" = [ "libreoffice-calc.desktop" ];
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" =
          [ "libreoffice-calc.desktop" ];
        "application/vnd.ms-powerpoint" = [ "libreoffice-impress.desktop" ];
        "application/vnd.openxmlformats-officedocument.presentationml.presentation" =
          [ "libreoffice-impress.desktop" ];
        "application/rtf" = [ "libreoffice-writer.desktop" ];
        "text/csv" = [ "libreoffice-calc.desktop" ];
      };
    };
  };
}

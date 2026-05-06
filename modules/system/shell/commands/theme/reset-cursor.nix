{ createCommand, pkgs, ... }:

createCommand {
  name = "theme-reset-cursor";
  buildInputs = with pkgs; [ uutils-coreutils-noprefix ];

  command = # bash
    ''
      rm -f ~/.gtkrc-2.0
      rm -f ~/.config/gtk-3.0/config.nixtra.ini
      rm -f ~/.config/gtk-4.0/config.nixtra.ini
      rm -f ~/.config/xsettingsd/xsettingsd.conf
      dconf reset -f /org/gnome/desktop/interface/cursor-theme
      dconf reset -f /org/gnome/desktop/interface/cursor-size
    '';
}

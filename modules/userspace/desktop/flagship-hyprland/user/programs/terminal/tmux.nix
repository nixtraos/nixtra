{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    clock24 = true;
    mouse = true;
    # Use 'a' as prefix (Ctrl-a) instead of default 'b'
    shortcut = "a";
    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      {
        plugin = catppuccin;
        extraConfig = "set -g @catppuccin_flavor 'mocha'";
      }
    ];
    extraConfig = # bash
      ''
        # Start windows and panes at 1, not 0
        set -g base-index 1
        setw -g pane-base-index 1

        # Fix colors for Kitty
        set -g default-terminal "xterm-kitty"

        # NOTE: Required by image plugin in neovim to be able
        # to send escape sequences (tmux disables by default for
        # security).
        set -g allow-passthrough on

        # The actual backend
        set -g default-shell ${
          pkgs.${config.nixtra.user.shell}
        }/bin/${config.nixtra.user.shell};
      '';
  };
}

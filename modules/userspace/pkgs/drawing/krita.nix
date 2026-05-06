{
  config,
  pkgs,
  nixtraLib,
  ...
}:

let
  # Remove the RecentFiles history on startup
  kritaWrapper = pkgs.writeShellScriptBin "krita" ''
    CONFIG_FILE="$HOME/.config/kritarc"

    # make krita respect kvantum theme (which is for qt5 only)
    export KRITA_NO_STYLE_OVERRIDE=1

    clear_recent_files() {
      if [ -f "$CONFIG_FILE" ]; then
        awk '
          BEGIN { skip=0 }
          /^\[RecentFiles\]/ { print; skip=1; next }
          /^\[/ && skip { skip=0 }
          !skip
        ' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
      fi
    }

    clear_recent_files
    ${pkgs.krita}/bin/krita "$@"
    clear_recent_files
  '';
in
{
  #programs.krita.enable = true;

  home.packages = with pkgs; [
    (nixtraLib.sandbox.wrapFirejail {
      executable = "${kritaWrapper}/bin/krita";
      applications = "${pkgs.krita}/share/applications";
      #desktop = "${pkgs.krita}/share/applications/krita.desktop";
      profile = "krita";
    })
    krita
  ];
}

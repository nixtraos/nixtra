{
  config,
  pkgs,
  createCommand,
  ...
}:

createCommand {
  name = "run-if-active";
  prefix = "desktop";
  buildInputs = with pkgs; [ jq ];
  command = # bash
    ''
      # Log output
      #LOGFILE="/tmp/my-hypr-script.log"
      #exec > >(tee -a "$LOGFILE") 2>&1

      ACTIVE_WORKSPACE=$(hyprctl activewindow -j | jq -r '.workspace.name')
      if [[ "$ACTIVE_WORKSPACE" == "$1" ]]; then
        eval "$2"
      else
        hyprctl dispatch sendshortcut CONTROL_L, Z, activewindow
      fi
    '';
}

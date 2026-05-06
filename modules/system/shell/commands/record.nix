{
  config,
  pkgs,
  createCommand,
  ...
}:

createCommand {
  name = "record";
  buildInputs = with pkgs; [
    gawk
    coreutils
    findutils
    wf-recorder
    slurp
  ];

  # https://gist.github.com/raffaem/bb9c35c6aab663efd7a0400c33d248a1
  command = # bash
    ''
      pidf="$HOME/Videos/Screencasts/process.pid"
      WF_RECORDER_OPTS=""
      VIDEOEXT="mkv"

      status() {
          if [ -f "$pidf" ]; then
              awk 'BEGIN{printf "{\"text\":\"\", \"tooltip\":\"Recording\\n"}
              NR==1{printf "PID: %s\\n", $0}
              NR==2{printf "Save to: %s\\n", $0}
              NR==3{printf "Log to: %s\"}", $0}' "$pidf"
              ${pkgs.coreutils}/bin/echo '{"text":"", "tooltip":"Recording"}'
          else
              ${pkgs.coreutils}/bin/echo '{"text":"", "tooltip":"Stopped"}'
          fi
      }

      toggle() {
          if [ -f "$pidf" ]; then
              read -r pid < "$pidf"
              ${pkgs.coreutils}/bin/kill -2 "$pid"
              ${pkgs.coreutils}/bin/rm "$pidf"
          else
              ${pkgs.coreutils}/bin/mkdir -p "$HOME/Videos/Screencasts"
              bf="$HOME/Videos/Screencasts/$(date +'%Y%m%dT%H%M%S')"
              vidf="$bf.$VIDEOEXT"
              logf="$bf.log"

              if [ "$1" == "fullscreen" ]; then
                  ${pkgs.wf-recorder}/bin/wf-recorder $WF_RECORDER_OPTS -f "$vidf" > "$logf" 2>&1 &
              elif [ "$1" == "region" ]; then
                  ${pkgs.coreutils}/bin/sleep 1
                  ${pkgs.wf-recorder}/bin/wf-recorder $WF_RECORDER_OPTS -g "$(${pkgs.slurp}/bin/slurp)" -f "$vidf" > "$logf" 2>&1 &
              else
                  ${pkgs.coreutils}/bin/echo "Argument $1 not valid"
                  exit 1
              fi

              pid=$!
              printf "%d\n%s\n%s" "$pid" "$vidf" "$logf" > "$pidf"
          fi
      }

      case "$1" in
          status)
              status
              ;;
          toggle)
              if [ -z "$2" ]; then
                  ${pkgs.coreutils}/bin/echo "Usage: $0 toggle [fullscreen|region]"
                  exit 1
              fi
              toggle "$2"
              ;;
          *)
              ${pkgs.coreutils}/bin/echo "Usage: $0 {status|toggle}"
              exit 1
              ;;
      esac
    '';
}

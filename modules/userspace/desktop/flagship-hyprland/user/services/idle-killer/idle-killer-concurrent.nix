{ pkgs, createCommand, ... }:

createCommand {
  name = "idle-killer-concurrent";
  buildInputs = with pkgs; [
    jq
    hyprland
  ];
  prefix = "";
  command = # bash
    ''
      IFS=$'\n\t'

      # --- Helpers & bootstrap ---
      SCRIPT_NAME="$(basename "$0")"
      CONFIG_PATH="''${XDG_CONFIG_HOME:-$HOME/.config}/idle-killer/config"
      if [[ -f "$CONFIG_PATH" ]]; then
        # shellcheck source=/dev/null
        source "$CONFIG_PATH"
      else
        echo "Config not found at $CONFIG_PATH" >&2
        exit 1
      fi

      HYPRCTL="$(command -v hyprctl || true)"
      if [[ -z "$HYPRCTL" ]]; then
        echo "hyprctl not found in PATH — this must run inside a Hyprland session." >&2
        exit 2
      fi

      log() { logger -t "$LOGTAG" -- "$SCRIPT_NAME: $*"; }

      # Map of timers
      declare -A timers
      declare -A running_cache  # whether app is currently running (string "1"/"0")

      # Initialize list of managed apps from config
      function get_managed_list() {
        local arr=()
        if [[ -z "''${MANAGED_APPS// }" ]]; then
          # Managed list from APP_TIMEOUTS keys
          for k in "''${!APP_TIMEOUTS[@]}"; do
            arr+=("$k")
          done
        else
          # split MANAGED_APPS on whitespace
          read -ra arr <<<"$MANAGED_APPS"
        fi
        echo "''${arr[@]}"
      }

      MANAGED=( $(get_managed_list) )
      if [[ ''${#MANAGED[@]} -eq 0 ]]; then
        log "No managed apps found in config; nothing to do."
        exit 0
      fi

      # get timeout for app class
      get_timeout_for() {
        local app="$1"
        if [[ -n "''${APP_TIMEOUTS[$app]:-}" ]]; then
          echo "''${APP_TIMEOUTS[$app]}"
        else
          echo "$DEFAULT_TIMEOUT"
        fi
      }

      # parse focused window: try JSON first, fallback to text
      get_focused_class_and_pid() {
        local j
        if j="$($HYPRCTL activewindow -j 2>/dev/null || true)"; then
          if [[ -n "$j" ]]; then
            local cls pid
            cls="$(printf '%s' "$j" | jq -r '.class // empty')"
            pid="$(printf '%s' "$j" | jq -r '.pid // empty')"
            echo "''${cls}|''${pid}"
            return
          fi
        fi
      }

      # get PIDs of app class (via clients -j if jq available, else parse)
      get_pids_for_class() {
        local app="$1"
        $HYPRCTL clients -j 2>/dev/null | jq -r --arg a "$app" '.[] | select(.class == $a) | .pid' 2>/dev/null || true
      }

      # check unfinished work hook: /usr/local/bin/idle-killer-check-<class>
      has_unfinished_work() {
        local app="$1"
        local hook="''${UNFINISHED_HOOK_PREFIX}''${app}"
        if [[ -x "$hook" ]]; then
          # hook returns 0 => has unfinished work (skip kill)
          "$hook"
          return $?
        fi
        return 1  # default: no unfinished work (1 means OK to kill in our convention)
      }

      # kill given pids (tries TERM then KILL after grace)
      kill_pids() {
        local app="$1"; shift
        local pids=("$@")
        if [[ ''${#pids[@]} -eq 0 ]]; then
          if [[ "$KILL_METHOD" == "pkill" ]]; then
            log "Attempting pkill for $app"
            pkill -f "$app" || true
          fi
          return
        fi
        log "Sending TERM to ''${pids[*]} for app=$app"
        kill "''${pids[@]}" 2>/dev/null || true
        sleep "$KILL_GRACE"
        # check which still exist
        local alive=()
        for p in "''${pids[@]}"; do
          if kill -0 "$p" 2>/dev/null; then
            alive+=("$p")
          fi
        done
        if [[ ''${#alive[@]} -gt 0 ]]; then
          log "Sending KILL to ''${alive[*]} for app=$app"
          kill -9 "''${alive[@]}" 2>/dev/null || true
        fi
      }

      # initialize timers for managed apps
      for a in "''${MANAGED[@]}"; do
        timers["$a"]=$(get_timeout_for "$a")
        running_cache["$a"]="0"
      done

      trap 'log "Received termination; exiting"; exit 0' SIGINT SIGTERM

      log "Starting concurrent idle-killer for: ''${MANAGED[*]} (poll=''${POLL_INTERVAL}s)"

      # --- Main loop ---
      while true; do
        # get focused class/pid
        IFS='|' read -r focused_class focused_pid <<< "$(get_focused_class_and_pid)"

        # get clients once per loop (cache)
        clients_json="$($HYPRCTL clients -j 2>/dev/null || echo ''')"

        for app in "''${MANAGED[@]}"; do
          # check if app is running (get pids)
          pids=( $(get_pids_for_class "$app") )
          if [[ ''${#pids[@]} -gt 0 ]]; then
            running_cache["$app"]="1"
          else
            running_cache["$app"]="0"
            # reset timer while not running
            timers["$app"]="$(get_timeout_for "$app")"
            continue
          fi

          # If focused, reset timer
          if [[ -n "$focused_class" && "$focused_class" == "$app" ]]; then
            timers["$app"]="$(get_timeout_for "$app")"
            continue
          fi

          # If unfinished work reported, skip decrement
          if has_unfinished_work "$app"; then
            # skip decrement
            continue
          fi

          # Decrement timer
          current="''${timers[$app]}"
          # ensure numeric
          if ! [[ "$current" =~ ^[0-9]+$ ]]; then
            current="$(get_timeout_for "$app")"
          fi
          new=$(( current - POLL_INTERVAL ))
          timers["$app"]="$new"

          if (( new <= 0 )); then
            log "Timer expired for app=$app; killing PIDs: ''${pids[*]}"
            kill_pids "$app" "''${pids[@]}"
            # reset timer
            timers["$app"]="$(get_timeout_for "$app")"
          fi
        done

        sleep "$POLL_INTERVAL"
      done
    '';
}

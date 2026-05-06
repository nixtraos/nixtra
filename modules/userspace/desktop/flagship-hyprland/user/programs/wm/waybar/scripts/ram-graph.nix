{
  config,
  pkgs,
  createCommand,
  ...
}:

createCommand {
  name = "ram-graph";
  buildInputs = with pkgs; [ gawk ];
  prefix = "";

  command = # bash
    ''
      LOGFILE="/tmp/my-hypr-script.log"
      exec > >(tee -a "$LOGFILE") 2>&1

      HISTORY_LENGTH=10  # Number of data points for the graph
      GRAPH_CHARS=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")

      declare -a history
      for ((i=0; i<HISTORY_LENGTH; i++)); do history[i]="0"; done

      while true; do
        ram_percent=$(free -m | awk '/Mem:/ {printf "%.0f", $3/$2*100}')

        history=("''${history[@]:1}" "$ram_percent")

        graph=""
        for perc in "''${history[@]}"; do
          index=$(( (perc * ''${#GRAPH_CHARS[@]}) / 100 ))
          [[ $index -ge ''${#GRAPH_CHARS[@]} ]] && index=$((''${#GRAPH_CHARS[@]}-1))
          graph+="''${GRAPH_CHARS[$index]}"
        done

        echo "{\"text\":\"$graph $ram_percent%\", \"tooltip\":\"RAM History: ''${history[*]}%\"}"
      done
    '';
}

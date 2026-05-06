{
  config,
  pkgs,
  createCommand,
  ...
}:

createCommand {
  prefix = "desktop";
  name = "schedule-reminder";
  buildInputs = with pkgs; [ libnotify ];

  command = # bash
    ''
      if ! command -v notify-send &>/dev/null; then
        echo "Error: notify-send (from libnotify) is not found."
        echo "Please install it to use this reminder script."
        exit 1
      fi

      if [ "$#" -ne 2 ]; then
        echo "Usage: $0 <time_in_seconds> <\"reminder_message\">"
        echo "Example: $0 3600 \"Take a break!\""
        exit 1
      fi

      time_in_seconds="$1"
      reminder_message="$2"

      if ! [[ "$time_in_seconds" =~ ^[0-9]+$ ]] || [ "$time_in_seconds" -le 0 ]; then
        echo "Error: <time_in_seconds> must be a positive integer."
        exit 1
      fi

      # Detach the script from the parent shell and run in the background
      # The 'exec' command replaces the current shell process with the sleep command,
      # then when sleep finishes, it executes notify-send.
      # nohup makes sure the process isn't terminated when the parent shell closes.
      # The '&' puts it in the background.
      nohup bash -c "sleep $time_in_seconds && notify-send -a 'Hyprland Reminder' 'Reminder' '$reminder_message'" &>/dev/null &

      echo "Reminder set for $time_in_seconds seconds from now: \"$reminder_message\""
      echo "You can close this shell; the reminder will still be displayed."
    '';
}

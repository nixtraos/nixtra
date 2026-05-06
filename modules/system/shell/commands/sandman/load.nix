{ pkgs, createCommand, ... }:

createCommand {
  name = "load";
  prefix = "sandman";

  buildInputs = with pkgs; [ python3 ];

  command = # bash
    ''
      CONFIG_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/sandman"
      SANDBOX_DIR="$HOME/Sandbox"

      ${./verify_sandman.py}

      if [ $? -ne 0 ]; then
        echo "Signature validation failed. Aborting."
      fi

      for cfg in "$CONFIG_DIR"/*.mounts; do
        program=$(basename "$cfg" .mounts)
        sandbox_path="$SANDBOX_DIR/$program"
        while IFS= read -r dir; do
          mountpoint="$sandbox_path/$(basename "$dir")"
          mkdir -p "$mountpoint"
          # check if already mounted before mounting
          if ! mountpoint -q "$mountpoint"; then
            sudo mount --bind "$dir" "$mountpoint"
          fi
        done < "$cfg"
      done

      echo "Sandbox directories reloaded."
    '';
}

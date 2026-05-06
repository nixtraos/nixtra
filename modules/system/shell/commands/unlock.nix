{ config, createCommand, ... }:

createCommand {
  name = "unlock";
  buildInputs = [ ];

  command = # bash
    ''
      set -e

      if [ -z "$1" ]; then
        echo "Usage: $0 <file>"
        exit 1
      fi

      TARGET_FILE_PATH=$(readlink -f $1)

      rm -f $1
      cp "$TARGET_FILE_PATH" $1
      chown ${config.nixtra.user.username}:users $1
      chmod +w $1
    '';
}

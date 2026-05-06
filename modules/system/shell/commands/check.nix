{ pkgs, createCommand, ... }:

createCommand {
  name = "check";
  command = # bash
    ''
      set -e
      ORIGINAL_DIR="$(pwd)"
      trap 'cd "$ORIGINAL_DIR"' EXIT

      cd /etc/nixos
      git add --intent-to-add .
      cd - > /dev/null
    '';
}

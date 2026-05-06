{
  nixtraLib,
  pkgs,
  config,
  createCommand,
  ...
}:

createCommand {
  name = "rebuild";
  buildInputs = with pkgs; [
    openssl
  ];
  requireRoot = true;
  command = # bash
    ''
      ORIGINAL_DIR="$(pwd)"
      trap 'cd "$ORIGINAL_DIR"' EXIT

      BACKUP_DIR="/var/backups/nixos-backups/localhost"
      BACKUP_PW="nixtra" # stub for now
      MAX_KEEP=25

      mkdir -p "$BACKUP_DIR"
      chown root:root "$BACKUP_DIR"
      chmod 700 "$BACKUP_DIR"

      cd /etc/nixos
      git add --intent-to-add .
      cd - > /dev/null
      rm -rf /home/${config.nixtra.user.username}/.cache/nix/tarball-cache
      nixos-rebuild switch --flake /etc/nixos "$@"

      TIMESTAMP=$(date -u +"%Y%m%dT%H%M%SZ")
      GITREV=$(git -C /etc/nixos rev-parse --short=8 2>/dev/null || echo unknown)
      BACKUP_NAME="nixos-backup-''${TIMESTAMP}-''${GITREV}.tar.gz.enc"
      BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

      # - tar: create gzipped tar of /etc/nixos (stored with relative paths)
      # - openssl: AES-256-CBC encryption with PBKDF2 (password-based)
      tar -C /etc -czf - nixos \
        | openssl enc -aes-256-cbc -pbkdf2 -salt -pass pass:"$BACKUP_PW" -out "$BACKUP_PATH"

      chmod 600 "$BACKUP_PATH"
      chown root:root "$BACKUP_PATH"

      mapfile -t backups < <(ls -1t "$BACKUP_DIR"/nixos-backup-*.tar.gz.enc 2>/dev/null)

      if [ "''${#backups[@]}" -gt "$MAX_KEEP" ]; then
        echo "Rotating backups (keeping the $MAX_KEEP most recent)..."

        old_backups=("''${backups[@]:$MAX_KEEP}")

        for file in "''${old_backups[@]}"; do
          if [ -f "$file" ]; then
            rm -f "$file"
          fi
        done
      fi

      echo "Backup written to: $BACKUP_PATH"
    '';
}

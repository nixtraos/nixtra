{ config, createCommand, ... }:

createCommand {
  name = "restore-backup";
  command = # bash
    ''
      ORIGINAL_DIR="$(pwd)"
      trap 'cd "$ORIGINAL_DIR"' EXIT

      BACKUP_DIR="/var/backups/nixos-backups/localhost"

      # Ensure backup dir exists
      if [ ! -d "$BACKUP_DIR" ]; then
        echo "No backup directory found at $BACKUP_DIR"
        exit 1
      fi

      # Collect backups (newest first)
      mapfile -t files < <(ls -1t "$BACKUP_DIR"/nixos-backup-*.tar.gz.enc 2>/dev/null || true)

      if [ "''${#files[@]}" -eq 0 ]; then
        echo "No backups found in $BACKUP_DIR"
        exit 1
      fi

      echo "Available backups:"
      i=1
      for f in "''${files[@]}"; do
        # show size and mtime for readability
        statinfo=$(stat -c "%y %s bytes" "$f" 2>/dev/null || echo "")
        printf "  %2d) %s  —  %s\n" "$i" "$(basename "$f")" "$statinfo"
        i=$((i + 1))
      done

      # choose
      read -p $'Enter the number of the backup to restore (or q to quit): ' sel
      if [ "''${sel:-}" = "q" ] || [ "''${sel:-}" = "Q" ]; then
        echo "Aborted."
        exit 0
      fi

      if ! [[ "$sel" =~ ^[0-9]+$ ]] ; then
        echo "Invalid selection."
        exit 1
      fi

      if [ "$sel" -lt 1 ] || [ "$sel" -gt "''${#files[@]}" ]; then
        echo "Selection out of range."
        exit 1
      fi

      chosen="''${files[$((sel - 1))]}"
      echo "You selected: $(basename "$chosen")"

      # Ask for password (secure)
      read -s -p "Enter decryption password: " BACKUP_PW
      echo
      if [ -z "''${BACKUP_PW:-}" ]; then
        echo "Empty password — aborting."
        exit 1
      fi

      # Create temp dir and cleanup on exit
      TMPDIR=$(mktemp -d)
      cleanup() {
        rm -rf -- "$TMPDIR"
      }
      trap cleanup EXIT

      echo "Decrypting and extracting backup..."
      # Decrypt and extract into $TMPDIR. The backup contains a top-level "nixos" directory (created by the backup command).
      if ! openssl enc -d -aes-256-cbc -pbkdf2 -in "$chosen" -pass pass:"$BACKUP_PW" 2>/dev/null | tar -xz -C "$TMPDIR"; then
        echo "Decryption/extraction failed — wrong password or corrupted file."
        exit 1
      fi

      # Verify we have the expected content
      if [ ! -d "$TMPDIR/nixos" ]; then
        echo "Extracted archive does not contain expected 'nixos' directory. Aborting."
        exit 1
      fi

      echo "Backup extracted to $TMPDIR/nixos"
      echo
      read -p $'This will overwrite /etc/nixos with the selected backup. Do you want to proceed? [y/N]: ' confirm
      case "$confirm" in
        y|Y) ;;
        *) echo "Aborted by user."; exit 0 ;;
      esac

      # Ensure we're root
      if [ "$(id -u)" -ne 0 ]; then
        echo "This restore must be run as root. Re-run with sudo or as root."
        exit 1
      fi

      # Make an encrypted pre-restore snapshot of current /etc/nixos (timestamped)
      TIMESTAMP=$(date -u +"%Y%m%dT%H%M%SZ")
      PRE_NAME="$BACKUP_DIR/nixos-pre-restore-''${TIMESTAMP}.tar.gz.enc"
      echo "Creating encrypted pre-restore snapshot at: $PRE_NAME (encrypted with the password you provided)..."
      # Use same password to encrypt pre-restore snapshot so it can be restored with same password.
      # If you prefer different handling (gpg, different key), change this behavior.
      tar -C /etc -czf - nixos \
        | openssl enc -aes-256-cbc -pbkdf2 -salt -pass pass:"$BACKUP_PW" -out "$PRE_NAME"
      chmod 600 "$PRE_NAME"
      chown root:root "$PRE_NAME"

      # Restore: rsync the extracted content into /etc/nixos
      echo "Restoring into /etc/nixos..."
      mkdir -p /etc/nixos
      # Use rsync to preserve metadata and delete removed files from the target to match the backup
      if ! command -v rsync >/dev/null 2>&1; then
        # fallback to tar+move if rsync is unavailable (less ideal)
        rm -rf /etc/nixos
        mv "$TMPDIR/nixos" /etc/nixos
      else
        rsync -a --delete "$TMPDIR/nixos/" /etc/nixos/
      fi

      echo "Restore complete. Pre-restore snapshot saved as: $(basename "$PRE_NAME")"
    '';
}

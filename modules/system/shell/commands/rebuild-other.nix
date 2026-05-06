{
  nixtraLib,
  lib,
  pkgs,
  config,
  createCommand,
  ...
}:

let
  profiles = builtins.attrNames (builtins.readDir ../../../../profiles);
  nixtraHosts = lib.filterAttrs (
    name: value: ((value.profile != "") && (builtins.elem value.profile profiles))
  ) config.nixtra.ssh.hosts;
in
(lib.mapAttrsToList (
  name: host:
  let
    hostName = builtins.elemAt host.hostNames 0;
  in
  (createCommand {
    name = "rebuild-${name}";
    buildInputs = with pkgs; [
      openssl
      openssh
    ];
    requireRoot = true;
    command = # bash
      ''
        ORIGINAL_DIR="$(pwd)"
        trap 'cd "$ORIGINAL_DIR"' EXIT

        # Backup configuration after successful rebuild
        BACKUP_DIR="/var/backups/nixos-backups/${host.profile}"
        BACKUP_PW="nixtra" # stub for now
        MAX_KEEP=25

        # Ensure backup dir exists and is secure
        mkdir -p "$BACKUP_DIR"
        chown root:root "$BACKUP_DIR"
        chmod 700 "$BACKUP_DIR"

        cd /etc/nixos
        git add --intent-to-add .
        rm -rf /home/${config.nixtra.user.username}/.cache/nix/tarball-cache # Workaround fix for root ownership permission issue
        mkdir -p ./builds/laptop
        #nixos-rebuild build --flake .#profile-${host.profile} "$@" --out-link ./builds/${host.profile}
        nix build .#nixosConfigurations."profile-${host.profile}".config.system.build.toplevel "$@" -o ./builds/laptop/result
        cd - > /dev/null

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

        # Rotation: keep only the most recent $MAX_KEEP backups, delete older ones.
        # This approach lists backups newest-first and removes entries from 26 onward.
        set -- "$BACKUP_DIR"/nixos-backup-*.tar.gz.enc
        if [ -e "$1" ]; then
          ls -1t "$BACKUP_DIR"/nixos-backup-*.tar.gz.enc \
            | tail -n +$((MAX_KEEP + 1)) \
            | while IFS= read -r oldf; do
                rm -f -- "$oldf" || true
              done
        fi

        echo "Backup written to: $BACKUP_PATH"

        cd /etc/nixos
        store_path=$(readlink -f "./builds/${host.profile}/result")
        nix copy --to ssh://root@${hostName} "$store_path"
        ssh "root@${hostName}" "$store_path/bin/switch-to-configuration switch"
        cd - > /dev/null
      '';
  })
) nixtraHosts)

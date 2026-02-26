{ pkgs, createCommand, ... }:

createCommand {
  name = "cli";
  prefix = "sandman";

  buildInputs = with pkgs; [ python3 rsync ];
  requireRoot = true;

  command = ''
    USERNAME=$(logname)
    HOME=$(getent passwd ''${USERNAME} | cut -d: -f6)

    CONFIG_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/sandman"
    LOCKFILE="$CONFIG_DIR.lock"
    SANDBOX_DIR="$HOME/Sandbox"

    mkdir -p "$CONFIG_DIR"

    refresh_program() {
      local program="$1"
      local config_file="$CONFIG_DIR/$program.mounts"

      mapfile -t desired_dirs < "$config_file" 2>/dev/null || desired_dirs=()

      # prepare list of mountpoints that *should* be mounted (target paths inside sandbox)
      declare -A desired_mountpoints=()
      for dir in "''${desired_dirs[@]}"; do
        base=$(basename "$dir")
        mountpoint="$SANDBOX_DIR/$program/$base"
        desired_mountpoints["$mountpoint"]=1
      done

      # list currently mounted bind mounts under SANDBOX_DIR
      current_mounts=()
      while read -r line; do
        # Each line is mountpoint path
        current_mounts+=("$line")
      done < <(mount | grep "on $SANDBOX_DIR" | grep "bind" | awk '{print $3}')

      # unmount any mounts under SANDBOX_DIR NOT in desired_mountpoints
      for mnt in "''${current_mounts[@]}"; do
        if [[ -z "''${desired_mountpoints[$mnt]}" ]]; then
          echo "Unmounting obsolete mount $mnt"
          umount "$mnt"
        fi
      done

      # mount desired directories that are not currently mounted
      for dir in "''${desired_dirs[@]}"; do
        base=$(basename "$dir")
        mountpoint="$SANDBOX_DIR/$program/$base"
        # check if already mounted
        if ! mountpoint -q "$mountpoint"; then
          echo "Mounting $dir -> $mountpoint"
          mkdir -p "$mountpoint"
          mount --bind "$dir" "$mountpoint"
        fi
      done
    }

    acquire_config_lock() {
      mkdir -p "$CONFIG_DIR"
      exec 200>"$LOCKFILE"
      flock -x 200
    }

    release_config_lock() {
      # release and close fd 200
      flock -u 200 || true
      exec 200>&-
    }

    # only local user can write (umask 077)
    make_secure_tmpdir() {
      #if [ -n "''${XDG_RUNTIME_DIR:-}" ]; then
      #  local base="''${XDG_RUNTIME_DIR}"
      #else
      #  local base="/tmp"
      #fi
      local base="/tmp"

      TMP_DIR=$(mktemp -d "''${base}/sandman.XXXXXX")

      echo "$TMP_DIR"
    }

    snapshot_config_to_tmp() {
      local src="$1"
      local dst="$2"

      rsync -a --delete --links --omit-dir-times --chmod=Du=rwx,Dg=,Do=,Fu=rw,Fg=,Fo= "$src"/ "$dst"/
    }

    # atomic swap: assumes caller holds the lock
    # newdir will be moved to targetdir, old targetdir is saved to bak and removed
    atomic_swap_dirs() {
      local newdir="$1"
      local targetdir="$2"

      local parent
      parent=$(dirname "$targetdir")
      local name
      name=$(basename "$targetdir")
      local bak="$parent/$name.bak.$(date +%s).$$"

      # ensure same parent fs for cheap renames; failing that, copy+move fallback
      if [ "$(df --output=source "$newdir" | tail -1)" = "$(df --output=source "$parent" | tail -1)" ]; then
        # Move original out of the way (rename is atomic)
        if [ -e "$targetdir" ]; then
          mv "$targetdir" "$bak"
        fi
        mv "$newdir" "$targetdir"
        # remove backup
        if [ -e "$bak" ]; then
          rm -rf "$bak"
        fi
      else
        # fallback: copy into place (less ideal), but still done under lock
        rm -rf "$targetdir"
        mv "$newdir" "$targetdir"
      fi
    }

    warn() {
      if [ ! -e "$CONFIG_DIR/.signature.json" ]; then
        echo "Sandbox signature has not been created yet. You will need to pass a password to verify the content of the sandman configuration at runtime. It is recommended that you store this password in a local & encrypted password manager."
      fi
    }

    validate_sig() {
      warn
      ${./verify_sandman.py} $CONFIG_DIR
    }

    recompute_sig() {
      warn
      ${./sign_sandman.py} $CONFIG_DIR
    }

    CONFIG_DIR_ORIG=""
    lease_config() {
      if [ -n "$CONFIG_DIR_ORIG" ]; then
        echo "Config is already locked."
        return
      fi

      # acquire lock so nobody else can interfere
      acquire_config_lock

      TMP=$(make_secure_tmpdir)

      snapshot_config_to_tmp "$CONFIG_DIR" "$TMP"

      chown root:root "$TMP"
      chmod 700 "$TMP"

      CONFIG_DIR_ORIG=$CONFIG_DIR
      CONFIG_DIR=$TMP

      validate_sig
    }

    unlease_config() {
      if [ -z "$CONFIG_DIR_ORIG" ]; then
        echo "Config is not locked."
        return
      fi

      recompute_sig

      # flush metadata
      sync && sleep 0.1

      # atomically swap the TMP into place while still holding lock
      atomic_swap_dirs "$CONFIG_DIR" "$CONFIG_DIR_ORIG"

      # restore dir
      CONFIG_DIR=$CONFIG_DIR_ORIG
      CONFIG_DIR_ORIG=""
    }

    cleanup() {
      if [ -n "$CONFIG_DIR_ORIG" ]; then
        rm -rf "$CONFIG_DIR"
      fi

      release_config_lock
    }

    refresh_all() {
      shopt -s nullglob
      for cfg in "$CONFIG_DIR"/*.mounts; do
        program=$(basename "$cfg" .mounts)
        echo "Refreshing $program..."
        refresh_program "$program"
      done
      shopt -u nullglob
    }

    set +e
    lease_config
    lease_result=$?
    set -e

    trap cleanup EXIT HUP INT QUIT TERM

    if [ "$lease_result" -ne 0 ]; then
      echo "Signature validation failed. Either password is incorrect or sandbox configuration has been tampered with."
      read -p "Reset configuration & password? [y/N]: " answer
      if [[ "$answer" != "y" ]]; then
        exit 0
      fi

      if [ -n "$CONFIG_DIR" ]; then
        find "$CONFIG_DIR" -mindepth 1 -delete
      fi

      echo "Enter a new password."
      unlease_config

      echo "Sandbox configuration has been reset. Enter the program again to continue."
      exit 0
    fi

    select action in "Reload sandman" "Re-sign sandman" "Manage a sandbox" "Quit"; do
      case $action in
        "Reload sandman")
          refresh_all
          ;;
        "Re-sign sandman")
          recompute_sig
          ;;
        "Manage a sandbox")
          break
          ;;
        "Quit")
          exit 0
          ;;
        *)
          echo "Invalid option"
          ;;
      esac
    done

    echo "Available sandboxed programs:"
    programs=()
    while IFS= read -r -d "" dir; do
      programs+=("$(basename "$dir")")
    done < <(find "$SANDBOX_DIR" -mindepth 1 -maxdepth 1 -type d -print0)

    select program in "''${programs[@]}"; do
      [[ -n "$program" ]] && break
      echo "Invalid selection"
    done

    CONFIG_FILE="$CONFIG_DIR/$program.mounts"

    echo "Selected program: $program"
    echo "Choose an action:"
    select action in "Add directory" "Remove directory" "List directories" "Finish"; do
      case $action in
        "Add directory")
          read -rp "Enter absolute path to directory to add: " dirpath
          grep -qxF "$dirpath" "$CONFIG_FILE" 2>/dev/null || echo "$dirpath" >> "$CONFIG_FILE"
          echo "Added directory. Reload required."
          ;;
        "Remove directory")
          if [[ ! -f "$CONFIG_FILE" ]]; then
            echo "No directories mounted."
          else
            mapfile -t mounts < "$CONFIG_FILE"
            if [[ ''${#mounts[@]} -eq 0 ]]; then
              echo "No directories mounted."
            else
              echo "Select directory to remove:"
              select dirpath in "''${mounts[@]}"; do
                if [[ -n "$dirpath" ]]; then
                  grep -vxF "$dirpath" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
                  echo "Removed directory. Reload required."
                  break
                else
                  echo "Invalid selection"
                fi
              done
            fi
          fi
          ;;
        "List directories")
          if [[ ! -f "$CONFIG_FILE" ]] || [[ ! -s "$CONFIG_FILE" ]]; then
            echo "No directories mounted."
          else
            echo "Currently mounted directories for $program:"
            cat "$CONFIG_FILE"
          fi
          ;;
        "Finish")
          unlease_config
          exit 0
          ;;
        *)
          echo "Invalid option"
          ;;
      esac
    done
  '';
}

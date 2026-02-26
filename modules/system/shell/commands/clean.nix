{ config, createCommand, ... }:

createCommand {
  name = "clean";
  buildInputs = [ ];

  command = # bash
    ''
      # Function to display a message with a timestamp
      log() {
        echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1"
      }

      log "Removing old system generations..."
      nix-env --delete-generations old
      if [ $? -eq 0 ]; then
        log "Old system generations removed successfully."
      else
        log "Failed to remove old system generations. Please check for errors."
        exit 1
      fi

      log "Cleaning up user profile generations..."
      nix-env --delete-generations old --profile /nix/var/nix/profiles/per-user/$USER/profile
      if [ $? -eq 0 ]; then
        log "User profile generations cleaned up successfully."
      else
        log "Failed to clean up user profile generations. Please check for errors."
        exit 1
      fi

      log "Running garbage collection to remove unused packages..."
      nix-collect-garbage --delete-old
      if [ $? -eq 0 ]; then
        log "Garbage collection completed successfully."
      else
        log "Garbage collection failed. Please check for errors."
        exit 1
      fi

      log "Optimizing the Nix store..."
      nix-store --optimise
      if [ $? -eq 0 ]; then
        log "Nix store optimization completed successfully."
      else
        log "Nix store optimization failed. Please check for errors."
        exit 1
      fi

      log "Cleaning up temporary files..."
      find /tmp -type f -atime +7 -delete
      find /var/tmp -type f -atime +7 -delete
      find /tmp -type d -empty -atime +3 -delete
      find /var/tmp -type d -empty -atime +3 -delete
      log "Temporary files cleanup completed."

      log "Cleaning up flake caches..."
      rm -rf ~/.cache/nix/eval-cache-v*
      rm -rf ~/.cache/nix/flake-registry.json
      log "Flake caches cleaned up."

      log "Cleaning up Nix build logs..."
      rm -rf /nix/var/log/nix/drvs/*
      log "Nix build logs cleaned up."

      log "Clearing local Nix build cache..."
      rm -rf ~/.cache/nix/drvs
      rm -rf ~/.cache/nix/tarball-cache
      log "Local Nix build cache cleared."

      log "Cleaning up flake caches..."
      rm -rf ~/.cache/nix/eval-cache-v*
      rm -rf ~/.cache/nix/flake-registry.json
      log "Flake caches cleaned up."

      log "Cleaning up old profiles..."
      nix-store --gc --print-roots | egrep -v "^(/nix/var|/run/\w+-system|\{memory|/proc)"
      log "Old profiles cleaned up."

      log "Cleaning up Home Manager backup files..."
      find /home/${config.nixtra.user.username} -type f -name "*.hm.backup.*" -exec rm -f {} \;
      log "Home Manager backup files cleaned up."

      log "Cleaning up 'core' dump files..."
      find {/etc/nixos,/root,$HOME} -type f -name 'core*' -print0 | while IFS= read -r -d "" file; do
        if file "$file" | grep -qiE 'core (file|dump)'; then
          rm -f -- "$file"
        fi
      done

      log "Refreshing the system's font cache..."
      fc-cache -f -v
      log "Refreshed the system's font cache."

      log "Removing unused development environments..."
      find /tmp -maxdepth 1 -type d -name "nix-shell-*" -exec rm -rf {} +
      find /tmp -maxdepth 1 -type d -name "nix-develop-*" -exec rm -rf {} +
      log "Unused development environments cleaned up."

      log "Checking and fixing Nix store corruptions..."
      sudo nix-store --verify --check-contents --repair
      log "Finished checking and fixing Nix store corruptions."

      log "NixOS cleanup completed successfully!"
    '';
}

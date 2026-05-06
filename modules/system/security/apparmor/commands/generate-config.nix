{ createCommand, ... }:

createCommand {
  prefix = "apparmor";
  name = "generate-config";
  command = # bash
    ''
      # Script to generate AppArmor configuration entries
      # This script queries the nix-store for apparmor-d profiles and generates
      # configuration entries for executables that exist on the system

      usage() {
          echo "Usage: $0"
          echo "Generates AppArmor configuration entries for profiles in /run/current-system"
          echo "Output format: executable = \"enforce\";"
      }

      # Help
      if [[ "''${1:-}" == "-h" ]] || [[ "''${1:-}" == "--help" ]]; then
          usage
          exit 0
      fi

      # Main logic
      main() {
          # Query nix-store for list of apparmor-d requisites
          local apparmor_requisites
          if ! apparmor_requisites=$(nix-store --query --requisites /run/current-system | grep apparmor-d); then
              echo "Error: No apparmor-d packages found in /run/current-system requisites"
              exit 1
          fi

          while IFS= read -r apparmor_path; do
              local apparmor_profiles_dir="''${apparmor_path}/etc/apparmor.d"

              # Check if the profiles directory exists
              if [[ ! -d "$apparmor_profiles_dir" ]]; then
                  echo "Warning: Directory $apparmor_profiles_dir does not exist, skipping..."
                  continue
              fi

              # Process each profile in the directory
              for profile in "$apparmor_profiles_dir"/*; do
                  # Skip if no files match the glob
                  [[ -e "$profile" ]] || continue

                  # Extract the base filename
                  local profile_name
                  profile_name=$(basename "$profile")

                  # Extract the executable name (everything before first non-alphabetic character)
                  local executable_name="''${profile_name%%[^[:alpha:]]*}"

                  # Skip if executable name is empty
                  [[ -n "$executable_name" ]] || continue

                  # Check if the executable exists in PATH
                  if command -v "$executable_name" &> /dev/null; then
                      echo "    $profile_name = \"enforce\";"
                  fi
              done
          done <<< $apparmor_requisites
      }

      # Run main function
      main "$@"
    '';
}

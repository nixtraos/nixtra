{
  config,
  createCommand,
  lib,
  ...
}:

createCommand {
  name = "ai-prompt-context-builder";
  buildInputs = [ ];

  command = # bash
    ''
      #!/usr/bin/env bash

      keywords=(
        ${lib.concatStringsSep " " (map (word: "'${word}'") config.nixtra.ai.prompt.wordsToRedact)}
      )

      buffer=""


      echo "Context Builder started."
      echo "Commands:"
      echo "  file path <path>             - Add a specific file"
      echo "  file grep name <regex>       - Add files with matching names"
      echo "  file grep content <regex>    - Add files with matching content"
      echo "  dir path <path>              - Add all files in a directory recursively"
      echo "  dir grep name <regex>        - Add all files in directories matching regex"
      echo "  dir grep content <regex>     - Add all files in directories containing matching content"
      echo "  exit                         - Show buffer and exit"

      # Helper function to add a single file to the buffer
      add_file_to_buffer() {
          local filepath="$1"
          if [[ -f "$filepath" ]]; then
              local content
              content=$(cat "$filepath")
              buffer+="$filepath"$'\n'
              buffer+="\`\`\`"$'\n'
              buffer+="$content"$'\n'
              buffer+="\`\`\`"$'\n\n'
              echo "Added $filepath to buffer."
          fi
      }

      # Helper function to add all files in a directory recursively
      add_dir_to_buffer() {
          local dirpath="$1"
          if [[ -d "$dirpath" ]]; then
              while IFS= read -r file; do
                  add_file_to_buffer "$file"
              done < <(find "$dirpath" -type f)
          else
              echo "Error: Directory '$dirpath' not found."
          fi
      }

      while true; do
          read -p "context-builder> " -r -a args

          case "''${args[0]}" in
              file)
                  case "''${args[1]}" in
                      path)
                          [[ -z "''${args[2]}" ]] && echo "Error: Path required." || add_file_to_buffer "''${args[2]}"
                          ;;
                      grep)
                          regex="''${args[3]}"
                          [[ -z "$regex" ]] && echo "Error: Regex required." && continue

                          if [[ "''${args[2]}" == "name" ]]; then
                              mapfile -t files < <(find . -type f | grep -E "$regex")
                          elif [[ "''${args[2]}" == "content" ]]; then
                              mapfile -t files < <(grep -rIlE "$regex" .)
                          fi
                          for f in "''${files[@]}"; do add_file_to_buffer "$f"; done
                          ;;
                  esac
                  ;;

              dir)
                  case "''${args[1]}" in
                      path)
                          [[ -z "''${args[2]}" ]] && echo "Error: Path required." || add_dir_to_buffer "''${args[2]}"
                          ;;
                      grep)
                          regex="''${args[3]}"
                          [[ -z "$regex" ]] && echo "Error: Regex required." && continue

                          if [[ "''${args[2]}" == "name" ]]; then
                              # Find directories matching regex and add their contents
                              mapfile -t dirs < <(find . -type d | grep -E "$regex")
                              for d in "''${dirs[@]}"; do add_dir_to_buffer "$d"; done
                          elif [[ "''${args[2]}" == "content" ]]; then
                              # Find unique directories containing files that match regex
                              mapfile -t dirs < <(grep -rIlE "$regex" . | xargs -L 1 dirname | sort -u)
                              for d in "''${dirs[@]}"; do add_dir_to_buffer "$d"; done
                          fi
                          ;;
                  esac
                  ;;

              exit)
                  for i in "''${!keywords[@]}"; do
                      buffer=$(echo "$buffer" | sed "s|''${keywords[$i]}|[REDACTED-$i]|gI")
                  done

                  # TODO: Consider disabling manually for less fingerprinting
                  # buffer+=$'\n'"Note: Certain keywords were replaced with [REDACTED-X] to secure the user's privacy; should these substitutions cause any syntactical errors, please ignore them accordingly."

                  echo -e "$buffer" | wl-copy
                  echo -e "Copied buffer to clipboard."
                  exit 0
                  ;;

              *)
                  [[ -n "''${args[0]}" ]] && echo "Unknown command: ''${args[0]}"
                  ;;
          esac
      done

    '';
}

{ createCommand, ... }:

createCommand {
  name = "hide-git-dir";
  buildInputs = [ ];

  command = # bash
    ''
      find "$1" -type d \( ! -name . \) -exec bash -c "cd '{}' && pwd && git ls-files -z $(pwd) | xargs -0 git update-index --skip-worktree" \;
    '';
}

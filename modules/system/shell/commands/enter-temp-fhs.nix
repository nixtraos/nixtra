{ createCommand, ... }:

createCommand {
  name = "enter-temp-fhs";
  buildInputs = [ ];

  command = # bash
    ''
      nix-shell -p steam-run --command "steam-run bash"
    '';
}

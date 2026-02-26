{ config, lib, pkgs, ... }:

{
  config = lib.mkIf (config.nixtra.user.shell.backend == "zsh") {
    environment.systemPackages = with pkgs; [ direnv ];

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      autosuggestions.enable = true;

      ohMyZsh = {
        enable = true;
        plugins =
          [ "git" "copyfile" "copybuffer" "dirhistory" "history" "direnv" ];
        theme = "robbyrussell";
      };

      shellInit = lib.concatStringsSep "\n"
        (lib.mapAttrsToList (name: value: ''export ${name}="${value}"'')
          config.nixtra.user.shell.environmentVariables);

      interactiveShellInit = lib.mkOrder 1500 ''
        if command -v nix-your-shell > /dev/null; then
          nix-your-shell zsh | source /dev/stdin
        fi
      '';

      autosuggestions.strategy = [ "completion" "history" ];
    };
  };
}

{
  nixtraLib,
  lib,
  config,
  pkgs,
  ...
}:

let
  greeting = nixtraLib.command.createCommand {
    name = "greeting";
    prefix = "";
    buildInputs = with pkgs; [
      fortune
      cowsay
      lolcat
    ];
    command = # bash
      ''
        # Only run in interactive shells
        #[[ $- != *i* ]] && exit 0

        echo ""

        HOUR=$(date +%H)
        HOUR_INT=$(printf "%d" "$HOUR")

        if (( HOUR_INT >= 6 && HOUR_INT < 12 )); then
          COW="tux"
        elif (( HOUR_INT >= 12 && HOUR_INT < 18 )); then
          COW="moose"
        elif (( HOUR_INT >= 18 && HOUR_INT < 22 )); then
          COW="dragon"
        else
          COW="ghostbusters"
        fi

        fortune | cowsay -f "$COW" | lolcat

        echo ""
      '';
  };
in
{
  environment.interactiveShellInit =
    lib.optionalString config.nixtra.fun.mysteriousFortuneCookie ''
      # want some fun?? :D
      "${greeting}/bin/greeting"
    ''
    + ''
      # prevent core dump file generation
      ulimit -c 0
    '';

  environment.systemPackages = with pkgs; [ nix-your-shell ];
}

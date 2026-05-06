{
  config,
  pkgs,
  lib,
  ...
}:

let
  torAliases =
    if config.nixtra.tor.aliases.enable then
      lib.listToAttrs (
        map (program: {
          name = builtins.baseNameOf program.program;
          value = "torsocks ${program.program}";
        }) (config.nixtra.tor.aliases.programs)
      )
    else
      { };

  aliasCacheDir = "$HOME/.cache/aliases";
  aliases = config.nixtra.shell.aliases;

  # TODO
  preemptiveScript = pkgs.writeShellScriptBin "preemptive" ''
    command=$1
    value=$2

    if [ ! -f "${aliasCacheDir}/$command" ]; then
      read -p "You are using the alias '$command' for the first time, which is mapped to '$value'. Press enter to continue."
      mkdir -p "${aliasCacheDir}"
      touch "${aliasCacheDir}/$command"
    fi

    $value "$@"
  '';
in
{
  imports = [ ../pkgs/cli/security.nix ];

  # environment.shellAliases = (builtins.mapAttrs (name: value: ''
  #   ${preemptiveScript}/bin/preemptive ${name} ${value} $@
  # '') config.nixtra.shell.aliases) // torAliases;

  environment.shellAliases = aliases // torAliases;
}

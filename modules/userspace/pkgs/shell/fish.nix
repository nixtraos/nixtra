{ config, lib, ... }:

{
  config = lib.mkIf (config.nixtra.user.shell.backend == "fish") {
    programs.fish.enable = true;
    programs.fish.shellInit = if config.nixtra.shell.fastfetchOnStartup then ''
      fastfetch
    '' else
      "";
  };
}

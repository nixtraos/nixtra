{ config, lib, ... }:

{
  config = lib.mkIf (config.nixtra.user.shell == "fish") {
    programs.fish.enable = true;
    programs.fish.shellInit =
      if config.nixtra.shell.fastfetchOnStartup then
        ''
          fastfetch
        ''
      else
        "";
  };
}

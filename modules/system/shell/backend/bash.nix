{ config, lib, ... }:

{
  config = lib.mkIf (config.nixtra.user.shell.backend == "zsh") {
    #programs.bash.enable = true;
  };
}

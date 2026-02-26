{ config, lib, ... }:

{
  config = lib.mkIf (config.nixtra.user.shell.backend == "bash") {
    #programs.bash.enable = true;
  };
}

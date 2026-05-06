{ config, lib, ... }:

{
  config = lib.mkIf (config.nixtra.user.shell == "bash") {
    #programs.bash.enable = true;
  };
}

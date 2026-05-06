{ config, lib, ... }:

{
  config = lib.mkIf (config.nixtra.user.shell == "zsh") {
    #programs.bash.enable = true;
  };
}

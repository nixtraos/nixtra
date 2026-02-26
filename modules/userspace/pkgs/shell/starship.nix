{ config, lib, pkgs, ... }:

{
  config = lib.mkIf (config.nixtra.user.shell.backend == "bash") {
    home.packages = with pkgs; [ starship ];

    programs.starship.enable = true;
    programs.starship.settings = { format = "  $all"; };
  };
}

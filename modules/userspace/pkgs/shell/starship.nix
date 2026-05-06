{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf (config.nixtra.user.shell == "bash") {
    home.packages = with pkgs; [ starship ];

    programs.starship.enable = true;
    programs.starship.settings = {
      format = "  $all";
    };
  };
}

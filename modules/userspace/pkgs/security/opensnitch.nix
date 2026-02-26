{ config, pkgs, ... }:

{
  # services.opensnitch-ui.enable = true;

  home.packages = with pkgs; [ opensnitch-ui ];
}

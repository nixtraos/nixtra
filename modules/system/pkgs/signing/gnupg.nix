{ config, pkgs, ... }:

{
  imports = [ ];

  environment.systemPackages = with pkgs; [
    gnupg
    pinentry-curses
  ];

  services.pcscd.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-tty;
    enableSSHSupport = true;
  };
}

{
  config,
  pkgs,
  nixtraLib,
  ...
}:

{
  programs.keepassxc.enable = true;

  home.packages = with pkgs; [
    (nixtraLib.sandbox.wrapFirejail {
      executable = "${pkgs.keepassxc}/bin/keepassxc";
      profile = "keepassxc";
    })
  ];
}

{
  config,
  nixtraLib,
  pkgs,
  ...
}:

{
  programs.mpv.enable = true;

  home.packages = [
    (nixtraLib.sandbox.wrapFirejail {
      executable = "${pkgs.mpv}/bin/mpv";
      profile = "mpv";
    })
  ];
}

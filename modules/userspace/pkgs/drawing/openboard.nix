{
  config,
  pkgs,
  nixtraLib,
  ...
}:

{
  home.packages = with pkgs; [
    (nixtraLib.sandbox.wrapFirejail {
      executable = "${pkgs.openboard}/bin/openboard"; # Whiteboard
      profile = "openboard";
    })
    openboard
  ];
}

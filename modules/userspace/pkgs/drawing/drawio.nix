{
  config,
  pkgs,
  nixtraLib,
  ...
}:

{
  home.packages = with pkgs; [
    drawio # Infrastructure diagrams
    (nixtraLib.sandbox.wrapFirejail {
      executable = "${pkgs.drawio}/bin/drawio";
      profile = "drawio";
    })
  ];
}

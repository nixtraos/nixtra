{
  config,
  pkgs,
  nixtraLib,
  ...
}:

{
  home.packages = with pkgs; [
    (nixtraLib.sandbox.wrapFirejail {
      executable = "${pkgs.libreoffice}/bin/libreoffice";
      profile = "libreoffice";
    })
    pkgs.libreoffice
  ];
}

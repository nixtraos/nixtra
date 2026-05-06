{
  config,
  pkgs,
  nixtraLib,
  ...
}:

{
  home.packages = [
    (nixtraLib.sandbox.wrapFirejail {
      executable = "${pkgs.kdePackages.okular}/bin/okular";
      profile = "okular";
    })
    pkgs.kdePackages.okular
  ];
}

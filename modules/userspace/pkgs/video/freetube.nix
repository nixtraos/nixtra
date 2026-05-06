{
  config,
  pkgs,
  nixtraLib,
  ...
}:

{
  programs.freetube.enable = true;

  home.packages = with pkgs; [
    (nixtraLib.sandbox.wrapFirejail {
      executable = "${pkgs.freetube}/bin/freetube";
      profile = "freetube";
    })
  ];
}

{ pkgs, nixtraLib, ... }:

{
  home.packages = [
    (nixtraLib.sandbox.wrapFirejail {
      executable = (
        pkgs.lutris.override {
          extraPkgs =
            iPkgs: with iPkgs; [
              wineWowPackages.waylandFull
              winetricks
            ];
        }
      );
      profile = "lutris";
    })
    pkgs.lutris
  ];
}

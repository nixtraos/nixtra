{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    #python312Full
    #python312Packages.pip

    (pkgs.python312.withPackages (
      ppkgs: with ppkgs; [
        openai
        python-dotenv
        psutil
      ]
    ))
  ];
}

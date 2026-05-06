{
  config,
  pkgs,
  profileSettings,
  inputs,
  ...
}:

let
  gpuArchitecture = if config.nixtra.hardware.gpu == "nvidia" then "cuda" else "rocm";
in
{
  home.packages = with pkgs; [
    (inputs.comfyui.packages.${profileSettings.arch}.${gpuArchitecture})

    (python3.withPackages (
      ps: with ps; [
        ddt
        docutils
        imageio
        matplotlib
      ]
    ))
  ];
}

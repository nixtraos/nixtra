{ pkgs, ... }:

{
  home.packages = with pkgs; [
    upscayl
    upscayl-ncnn
  ];
}

{
  config,
  pkgs,
  ...
}:

{
  services.ollama = {
    enable = true;
    package = if config.nixtra.hardware.gpu == "amd" then pkgs.ollama-rocm else pkgs.ollama-cuda;
    acceleration =
      if config.nixtra.hardware.gpu == "amd" then
        "rocm"
      else if config.nixtra.hardware.gpu == "nvidia" then
        "cuda"
      else
        false;
    rocmOverrideGfx = "10.3.0";
  };
}

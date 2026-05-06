{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf (config.nixtra.audio.enable && config.nixtra.audio.backend == "pulseaudio") {
    hardware.pulseaudio.enable = true;
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf (config.nixtra.audio.enable && config.nixtra.audio.backend == "pipewire") {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = false;
      wireplumber.enable = true;
    };
    services.pipewire.extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 256;
        "default.clock.min-quantum" = 16;
        "default.clock.max-quantum" = 1024;
      };
      "resample-quality" = {
        "stream.properties" = {
          "resample.quality" = 4; # Highest quality
        };
      };
    };
  };
}

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    fastfetch
    speedtest-rs
    lm_sensors
  ];
}

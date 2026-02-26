{ config, lib, ... }:

{
  imports = [
    ./earlyoom.nix
    ./preload.nix
    ./laptop.nix
    ./irq.nix
    ./nic.nix
    ./ksm.nix
    ./hugepages.nix
    ./monit.nix
    ./smartd.nix
    ./watchdog.nix
  ];
}

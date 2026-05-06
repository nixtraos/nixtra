{ lib, config, ... }:

{
  config = lib.mkIf (config.nixtra.memory.swap.enable) {
    swapDevices = [
      {
        device = "/swapfile";
        randomEncryption.enable = config.nixtra.disk.encryption.enable;
        size = config.nixtra.memory.swap.size;
      }
    ];

    boot.kernel.sysctl."vm.zswap.enabled" = if config.nixtra.memory.swap.zswap then 1 else 0;
  };
}

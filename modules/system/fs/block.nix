{ ... }:

{
  hardware.block.scheduler = {
    "nvme[0-9]*" = "none";
  };
}

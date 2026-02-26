{ pkgs, config, lib, ... }:

{
  config = lib.mkIf (config.nixtra.system.filesystem == "btrfs") {
    services.btrfs.autoScrub.enable = true;
    services.btrfs.autoScrub.interval = "monthly";
    services.btrfs.autoScrub.fileSystems =
      [ "/" ]; # Only need to scrub the topmost subvolume

    fileSystems."/".options = [ "compress=zstd" "noatime" "autodefrag" ]
      ++ (if config.nixtra.disk.ssd then [ "ssd" ] else [ ]);
    fileSystems."/boot".options = [ "fmask=0022" "dmask=0022" ];

    # alternatively use `discard` filesystem option
    services.fstrim.enable = config.nixtra.disk.ssd;

    # btrfs snapshots
    # services.snapper = {
    #   snapshotInterval = "hourly";
    #   cleanupInterval = "1d";
    #   configs = {
    #     root = {
    #       SUBVOLUME = "/";
    #       TIMELINE_CREATE = true;
    #       TIMELINE_CLEANUP = true;
    #       TIMELINE_LIMIT_HOURLY = "10";
    #       TIMELINE_LIMIT_DAILY = "7";
    #       TIMELINE_LIMIT_WEEKLY = "0";
    #     };
    #   };
    # };
  };
}

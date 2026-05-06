{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf config.nixtra.performance.useHugePages {
    # reserve huge pages at boot
    boot.kernelParams = [
      # The size of each hugepage: for example "1G" for 1 GiB pages or "2M" for 2 MiB pages
      "hugepagesz=2M"
      # Number of huge pages to reserve
      "hugepages=512"
      # (Optional) If you want 1 GiB pages too:
      "hugepagesz=1G"
      "hugepages=4"
    ];

    systemd.mounts = [
      {
        where = "/dev/hugepages";
        enable = true;
        what = "hugetlbfs";
        type = "hugetlbfs";
        options = "pagesize=2M,mode=0755";
        # ensure it's mounted early
        requiredBy = [ "basic.target" ];
      }
      {
        where = "/dev/hugepages-1G";
        enable = true;
        what = "hugetlbfs";
        type = "hugetlbfs";
        options = "pagesize=1G,mode=0755";
        requiredBy = [ "basic.target" ];
      }
    ];

    # Transparent HugePages
    boot.kernel.sysctl = {
      "vm.nr_hugepages" = "512"; # matches what is set in kernelParams
      "vm.hugetlb_shm_group" = "1000";
      "vm.transparent_hugepage.enabled" = "always"; # or "madvise" or "never"
      "vm.transparent_hugepage.defrag" = "defer";
    };
  };
}

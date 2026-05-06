{ config, lib, ... }:

let
  cfg = config.nixtra.security.kernel;
in
{
  config = lib.mkIf config.nixtra.security.protectBoot {
    # https://madaidans-insecurities.github.io/guides/linux-hardening.html#boot-parameters
    boot.kernelParams = [
      # procfs hardening
      "proc.hidepid=2"
      "gid=proc"

      # make it harder to influence slab cache layout
      "slab_nomerge"
      # enables zeroing of memory during allocation and free time
      # Zero out memory at the time of initialization
      # helps mitigate use-after-free vulnerabilaties
      "init_on_alloc=1"
      "init_on_free=1"
      # randomizes page allocator freelist, improving security by
      # making page allocations less predictable
      "page_alloc.shuffle=1"
      # enables Kernel Page Table Isolation, which mitigates Meltdown and
      # prevents some KASLR bypasses
      "pti=on"
      # randomizes the kernel stack offset on each syscall
      # making attacks that rely on a deterministic stack layout difficult
      "randomize_kstack_offset=on"
      # disables vsyscalls, they've been replaced with vDSO
      "vsyscall=none"
      # disables debugfs, which exposes sensitive info about the kernel
      "debugfs=off"
      # prevents user space code escalation
      "lockdown=confidentiality"
      # "rd.udev.log_level=3"
      # "udev.log_priority=3"

      "random.trust_cpu=off"

      # USB / device initialization lockdown (optional, breaks some keyboards / devices)
      #"usbcore.authorized_default=0"
    ]
    ++
      lib.optionals
        # TODO: check if this causes freezes
        (config.nixtra.hardware.cpu == "amd" && cfg.encryptMemory)
        [
          # Memory encryption
          "mem_encrypt=on"
        ]
    ++ (
      if (!config.nixtra.debug.doVerboseKernelLogs) then
        [
          "mce=0"
          "quiet"
          "loglevel=0"
        ]
      else
        [ "loglevel=7" ]
    )
    ++ lib.optionals config.nixtra.security.kernel.aggressivePanic [
      # certain exploits cause an "oops", this makes the kernel panic if an "oops" occurs
      "oops=panic"
    ]
    ++ lib.optionals cfg.mitigateCommonVulnerabilities [
      # CPU mitigations & SMT handling (extreme: disable SMT)
      # this will make it so that your pc restarts automatically
      # if a kernel panic were to occur
      "mitigations=auto,nosmt" # enforce mitigations and disable SMT if needed

      # defend against common cpu vulnerabilities
      "spectre_v2=on"
      "spec_store_bypass_disable=on"
      "tsx=off"
      "tsx_async_abort=full,nosmt"
      "mds=full,nosmt"
      "l1tf=full,force"
      "nosmt=force"
    ]
    ++ lib.optionals cfg.enforceDmaProtection [
      # Runtime DMA protection / IOMMU
      "intel_iommu=on,igfx_off"
      "iommu.passthrough=0" # force DMA translations (avoid passthrough-by-default)
    ]
    ++ lib.optionals cfg.requireSignatures [
      # only alows kernel modules that have been signed with a valid key to be loaded
      # making it harder to load malicious kernel modules
      # can make VirtualBox or Nvidia drivers unusable
      "module.sig_enforce=1"
    ]
    ++ lib.optionals (config.nixtra.hardware.cpu == "intel") [ "intel_pstate=disable" ];

    # https://madaidans-insecurities.github.io/guides/linux-hardening.html#kasr-kernel-modules
    boot.blacklistedKernelModules = [
      # Obscure networking protocols
      "dccp" # Datagram Congestion Control Protocol
      "sctp" # Stream Control Transmission Protocol
      "rds" # Reliable Datagram Sockets
      "tipc" # Transparent Inter-Process Communication
      "n-hdlc" # High-level Data Link Control
      "ax25" # Amateur X.25
      "netrom" # NetRom
      "x25" # X.25
      "rose"
      "decnet"
      "econet"
      "af_802154" # IEEE 802.15.4
      "ipx" # Internetwork Packet Exchange
      "appletalk"
      "psnap" # SubnetworkAccess Protocol
      "p8023" # Novell raw IEE 802.3
      "p8022" # IEE 802.3
      "can" # Controller Area Network
      "atm"
      # Various rare filesystems
      "cramfs"
      "freevxfs"
      "jffs2"
      "hfs"
      "hfsplus"
      "udf"

      # "squashfs"  # compressed read-only file system used for Live CDs
      # "cifs"  # cmb (Common Internet File System)
      # "nfs"  # Network File System
      # "nfsv3"
      # "nfsv4"
      # "ksmbd"  # SMB3 Kernel Server
      # "gfs2"  # Global File System 2
      # vivid driver is only useful for testing purposes and has been the
      # cause of privilege escalation vulnerabilities
      # "vivid"
    ]
    ++ (if config.nixtra.security.disableUsbStorage then [ "usb_storage" ] else [ ]);

    # use hardened_malloc allocator
    # system-wide (global) memory allocator: options are
    # "libc" (default), "graphene-hardened", "graphene-hardened-light",
    # "jemalloc", "mimalloc", "scudo"
    #environment.memoryAllocator.provider = "graphene-hardened-light";
  };
}

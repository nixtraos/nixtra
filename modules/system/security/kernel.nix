# https://saylesss88.github.io/nix/hardening_NixOS.html

{ config, lib, ... }:

{
  config = lib.mkIf config.nixtra.security.protectKernel {
    security = {
      protectKernelImage = true;
      lockKernelModules = false; # this breaks iptables, wireguard, and virtd

      # force-enable the Page Table Isolation (PTI) Linux kernel feature
      forcePageTableIsolation = true;

      # User namespaces are required for sandboxing.
      # this means you cannot set `"user.max_user_namespaces" = 0;` in sysctl
      allowUserNamespaces = true;

      # Disable unprivileged user namespaces, unless containers are enabled
      #unprivilegedUsernsClone = config.virtualisation.containers.enable;
      unprivilegedUsernsClone = true;
      allowSimultaneousMultithreading = true;
    };

    # https://madaidans-insecurities.github.io/guides/linux-hardening.html
    boot.kernel.sysctl = lib.mkMerge [
      {
        # runtime protection
        "dev.tty.ldisc_autoload" = 0;
        "net.ipv4.conf.all.log_martians" = 1;

        "fs.suid_dumpable" = 0;
        # prevent pointer leaks
        "kernel.kptr_restrict" = 2;
        # Note: certain container runtimes or browser sandboxes might rely on the following
        # restrict eBPF to the CAP_BPF capability
        "kernel.unprivileged_bpf_disabled" = 1;
        # should be enabled along with bpf above
        # "net.core.bpf_jit_harden" = 2;
        # restrict loading TTY line disciplines to the CAP_SYS_MODULE
        "dev.tty.ldisk_autoload" = 0;
        # prevent exploit of use-after-free flaws
        "vm.unprivileged_userfaultfd" = 0;
        # kexec is used to boot another kernel during runtime and can be abused
        "kernel.kexec_load_disabled" = 1;
        # Kernel self-protection
        # SysRq exposes a lot of potentially dangerous debugging functionality to unprivileged users
        # 4 makes it so a user can only use the secure attention key. A value of 0 would disable completely
        "kernel.sysrq" = 4;
        # disable unprivileged user namespaces, Note: Docker, NH, and other apps may need this
        # "kernel.unprivileged_userns_clone" = 0; # commented out because it makes NH and other programs fail
        # restrict all usage of performance events to the CAP_PERFMON capability
        "kernel.perf_event_paranoid" = 3;

        # Network
        # protect against SYN flood attacks (denial of service attack)
        "net.ipv4.tcp_syncookies" = 1;
        # protection against TIME-WAIT assassination
        "net.ipv4.tcp_rfc1337" = 1;
        # enable source validation of packets received (prevents IP spoofing)
        "net.ipv4.conf.default.rp_filter" = 1;
        "net.ipv4.conf.all.rp_filter" = 1;

        "net.ipv4.conf.all.accept_redirects" = 0;
        "net.ipv4.conf.default.accept_redirects" = 0;
        "net.ipv4.conf.all.secure_redirects" = 0;
        "net.ipv4.conf.default.secure_redirects" = 0;
        # Protect against IP spoofing
        "net.ipv6.conf.all.accept_redirects" = 0;
        "net.ipv6.conf.default.accept_redirects" = 0;
        "net.ipv4.conf.all.send_redirects" = 0;
        "net.ipv4.conf.default.send_redirects" = 0;

        # prevent man-in-the-middle attacks
        "net.ipv4.icmp_echo_ignore_all" = 1;

        # ignore ICMP request, helps avoid Smurf attacks
        "net.ipv4.conf.all.forwarding" = 0;
        "net.ipv4.conf.default.accept_source_route" = 0;
        "net.ipv4.conf.all.accept_source_route" = 0;
        "net.ipv6.conf.all.accept_source_route" = 0;
        "net.ipv6.conf.default.accept_source_route" = 0;
        # Reverse path filtering causes the kernel to do source validation of
        "net.ipv6.conf.all.forwarding" = 0;
        "net.ipv6.conf.all.accept_ra" = 0;
        "net.ipv6.conf.default.accept_ra" = 0;

        ## TCP hardening
        # Prevent bogus ICMP errors from filling up logs.
        "net.ipv4.icmp_ignore_bogus_error_responses" = 1;

        # Disable TCP SACK
        "net.ipv4.tcp_sack" = 0;
        "net.ipv4.tcp_dsack" = 0;
        "net.ipv4.tcp_fack" = 0;

        # Userspace
        # restrict usage of ptrace
        "kernel.yama.ptrace_scope" = 2;

        # ASLR memory protection (64-bit systems)
        "vm.mmap_rnd_bits" = 32;
        "vm.mmap_rnd_compat_bits" = 16;

        # only permit symlinks to be followed when outside of a world-writable sticky directory
        "fs.protected_symlinks" = 1;
        "fs.protected_hardlinks" = 1;
        # Prevent creating files in potentially attacker-controlled environments
        "fs.protected_fifos" = 2;
        "fs.protected_regular" = 2;

        # Randomize memory
        "kernel.randomize_va_space" = 2;
        # Exec Shield (Stack protection)
        "kernel.exec-shield" = 1;

        ## TCP optimization
        # TCP Fast Open is a TCP extension that reduces network latency by packing
        # data in the sender’s initial TCP SYN. Setting 3 = enable TCP Fast Open for
        # both incoming and outgoing connections:
        "net.ipv4.tcp_fastopen" = 3;
        # Bufferbloat mitigations + slight improvement in throughput & latency
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.core.default_qdisc" = "cake";

        "vm.mmap_min_addr" = "65536"; # protect low memory (NULL-deref mitigation)
        "audit" = "1"; # enable audit subsystem early

        # use swap only if absolutely necessary
        # higher value is safer
        #"vm.swappiness" = "1";
        "vm.swappiness" = "60";
        "kernel.sched_child_runs_first" = 1;

        # accomodation for hardened memory allocator
        "vm.max_map_count" = "1048576";
      }
      (lib.mkIf config.nixtra.security.kernel.aggressivePanic {
        "kernel.panic_on_oops" = "1"; # panic if kernel oops occurs (avoid running a corrupted kernel)
      })
      # NOTE: this and aggressivePanic may cause minor driver hiccups, check if it is the freezing culprit
      (lib.mkIf config.nixtra.security.kernel.veryAggressivePanic {
        "kernel.panic_on_warn" = "1"; # panic on WARN path (optional)
      })
      (lib.mkIf config.nixtra.debug.doVerboseKernelLogs {
        "kernel.printk" = "7 7 7 7";
        # restrict kernel log to CAP_SYSLOG capability
        "kernel.dmesg_restrict" = 0;
      })
      (lib.mkIf (!config.nixtra.debug.doVerboseKernelLogs) {
        # reduce kernel debugging information which can be exploited
        "kernel.printk" = "3 3 3 3";
        # restrict kernel log to CAP_SYSLOG capability
        "kernel.dmesg_restrict" = 1;
      })
    ];
  };
}

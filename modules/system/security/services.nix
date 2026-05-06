{ config, lib, ... }:
let
  # Base hardening profile for all services
  baseHardening = {
    PrivateTmp = true;
    PrivateDevices = true;
    ProtectSystem = "strict";
    ProtectHome = "tmpfs";
    NoNewPrivileges = true;
    RestrictSUIDSGID = true;
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectControlGroups = true;
    #ProtectProc="invisible"
    #RestrictFileSystems=
    #ProtectKernelLogs="yes"
    RestrictAddressFamilies = [
      "AF_UNIX"
      "AF_INET"
      "AF_INET6"
    ];
    LockPersonality = true;
    SystemCallFilter = [
      "@system-service"
      "~@privileged"
      "~@resources"
    ];
    SystemCallArchitectures = "native";
    MemoryDenyWriteExecute = true;
    CapabilityBoundingSet = ""; # Default to empty for base
    #DynamicUser="yes"
  };

  # Service-specific overrides
  serviceOverrides = {
    NetworkManager = {
      CapabilityBoundingSet = [
        "CAP_NET_ADMIN"
        "CAP_NET_RAW"
        "CAP_NET_BIND_SERVICE"
      ];
      RestrictAddressFamilies = baseHardening.RestrictAddressFamilies ++ [ "AF_NETLINK" ];
    };

    docker = {
      CapabilityBoundingSet = [
        "CAP_CHOWN"
        "CAP_DAC_OVERRIDE"
        "CAP_FOWNER"
        "CAP_FSETID"
        "CAP_KILL"
        "CAP_NET_ADMIN"
        "CAP_NET_RAW"
        "CAP_SETGID"
        "CAP_SETPCAP"
        "CAP_SETUID"
        "CAP_SYS_ADMIN"
        "CAP_SYS_CHROOT"
        "CAP_MKNOD"
        "CAP_AUDIT_WRITE"
      ];
      # Note: DeviceAllow and DevicePolicy are often tricky with existing services.
      # Ensure these are truly needed or consider more specific udev rules.
      DeviceAllow = [
        "/dev/null rw"
        "/dev/urandom r"
        "char-pts rw"
      ];
      DevicePolicy = "closed";
    };

    libvirtd = {
      CapabilityBoundingSet = [
        "CAP_SYS_PTRACE"
        "CAP_NET_ADMIN"
        "CAP_IPC_LOCK"
      ];
      DeviceAllow = [
        "/dev/kvm rw"
        "/dev/vhost-net rw"
      ];
    };

    virtqemud = {
      CapabilityBoundingSet = [
        "CAP_SYS_PTRACE"
        "CAP_NET_ADMIN"
      ];
      DeviceAllow = [
        "/dev/kvm rw"
        "/dev/vhost-vsock rw"
      ];
    };

    pcscd = {
      CapabilityBoundingSet = [ "CAP_IPC_LOCK" ];
      DeviceAllow = [ "ccid rw" ];
    };

    # For user@.service, you usually configure it via users.users.<name>.extraConfig
    # or systemd.user.services."user@.service". However, directly overriding
    # "user@.service" in systemd.services usually applies to the template itself.
    # Be careful with this. For user sessions, you might want to look into
    # systemd.user.sessionVariables or similar.
    # For now, let's assume you want to harden the system's "user@.service" template.
    "user@.service" = {
      ProtectSystem = "full";
      ProtectHome = "read-only";
      CapabilityBoundingSet = [
        "CAP_SETUID"
        "CAP_SETGID"
        "CAP_SYS_PTRACE"
      ];
    };

    nix-daemon = {
      CapabilityBoundingSet = [
        "CAP_DAC_OVERRIDE"
        "CAP_FOWNER"
      ];
      # Merge SystemCallFilter:
      SystemCallFilter = baseHardening.SystemCallFilter ++ [ "@chown" ];
    };

    rtkit-daemon = {
      CapabilityBoundingSet = [
        "CAP_SYS_NICE"
        "CAP_SYS_RESOURCE"
      ];
      RestrictAddressFamilies = baseHardening.RestrictAddressFamilies ++ [ "AF_NETLINK" ];
    };

    getty = {
      CapabilityBoundingSet = [
        "CAP_SYS_ADMIN"
        "CAP_SYS_TTY_CONFIG"
      ];
      DeviceAllow = [ "/dev/tty rw" ];
    };
  };
in
{
  # Iterate over serviceOverrides and apply them as overrides to existing services
  systemd.services = lib.mapAttrs (name: overrides: {
    serviceConfig = baseHardening // overrides;
  }) serviceOverrides;
}

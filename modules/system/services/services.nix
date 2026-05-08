{ ... }:

{
  imports = [
    # Core
    ./fhs-permission-checker.nix

    # Components
    ./monitoring/monitoring.nix
    ./proxy/proxy.nix
    ./website/website.nix
    ./scheduling/tasks.nix
    ./virtualization/virtualization.nix
    ./container/container.nix
    ./synchronization/synchronization.nix
  ];
}

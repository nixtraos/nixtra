{ ... }:

{
  imports = [
    # Core
    ./fhs-permission-checker.nix

    # Proxy
    ./tor.nix
    ./microsocks.nix
    ./i2p.nix

    # Scheduling
    ./tasks.nix

    # Virtualization
    ./virt.nix

    ./nginx.nix
    ./miniflux.nix
  ];
}

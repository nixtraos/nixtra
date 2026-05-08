{
  lib,
  config,
  pkgs,
  ...
}:

{
  config = lib.mkIf (config.nixtra.hardware.gpu == "nvidia") {
    nixpkgs.config.cudaSupport = true;

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      open = false;

      package = config.boot.kernelPackages.nvidiaPackages.stable;

      modesetting = true;
      powerManagement = lib.mkIf config.nixtra.hardware.laptop {
        enable = true;
        finegrained = true; # turn off GPU when not in use
      };

      nvidiaSettings = true;
      prime.sync.enable = true;

      package = config.boot.kernelPackages.nvidiaPackages.production;

      # Make sure to enable NVIDIA Prime if you are on a laptop (offload mode) to keep the card powered down during normal use.
      prime = {
        # Enable Offload Mode
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };

        # YOU MUST REPLACE THESE WITH YOUR ACTUAL BUS IDS!
        # nix-shell -p pciutils --run "lspci | grep -i vga\|3d\|display"
        # You must convert the hex numbers before the colon into decimal integers for NixOS. For example:
        # E.g., if lspci shows 01:00.0, write "PCI:1:0:0"
        nvidiaBusId = "PCI:1:0:0";

        # Uncomment the correct line for your integrated GPU:
        #intelBusId = "PCI:0:2:0";
        #amdgpuBusId = "PCI:x:x:x";
      };
    };

    environment.systemPackages = with pkgs; [
      cudatoolkit # Essential for Machine Learning workflows
      nvtopPackages.nvidia # GPU process monitoring (like htop for GPUs)
      glxinfo # Tool to test 3D graphics/OpenGL configuration
      vulkan-tools # Tool to test Vulkan configuration
    ];

    # Ensure DRM and GBM support for Wayland
    environment.variables = {
      WLR_NO_HARDWARE_CURSORS = "1"; # Useful workaround for cursor issues
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      LIBVA_DRIVER_NAME = "nvidia";
    };

    # Required for NVIDIA Wayland support
    boot = {
      kernelParams = [ "nvidia-drm.modeset=1" ];
      kernelModules = [
        "nvidia"
        "nvidia_modeset"
        "nvidia_uvm"
        "nvidia_drm"
      ];
    };

    nixpkgs.config.allowUnfree = true;
  };
}

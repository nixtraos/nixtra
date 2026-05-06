{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf (config.nixtra.hardware.gpu == "amd") {
    nixpkgs.config.rocmSupport = true;

    # Enable AMD GPU
    boot.initrd.kernelModules = [ "amdgpu" ];
    services.xserver.videoDrivers = [ "amdgpu" ];

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        mesa
        #rocmPackages.hipcc
        rocmPackages.rocblas
        rocmPackages.hipblas
        rocmPackages.clr.icd
        rocmPackages.rocminfo
        vulkan-loader
      ];
      enable32Bit = true;
    };

    systemd.tmpfiles.rules = [
      "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
      #"L+    /run/opengl-driver   -   -   -   -    ${pkgs.mesa}"
    ];

    hardware.amdgpu.opencl.enable = true;

    # hardware.opengl.driSupport deprecated

    environment.systemPackages = with pkgs; [
      vulkan-tools
      clinfo
      rocmPackages.clr
      rocmPackages.rocminfo
      spirv-tools
      spirv-llvm-translator # Required for RustiCL
      amdgpu_top # GPU monitoring tool with GUI (launch using `amdgpu_top --gui`)
      radeontop # GPU monitoring tool with CLI
      furmark # Vulkan-based GPU benchmark and stress test
    ];

    # Enable ROCm for pre-VEGA AMD cards (e.g. RX 580)
    environment.variables = {
      ROC_ENABLE_PRE_VEGA = "1";
      #RUSTICL_ENABLE = "1";
      RUSTICL_ENABLE = "0";
    };
  };
}

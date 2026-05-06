{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nixtra.ai.comfyui;
  gpuArchitecture = if config.nixtra.hardware.gpu == "nvidia" then "cuda" else "rocm";
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      libdrm
    ];

    virtualisation.oci-containers.containers = {
      comfyui = {
        image = "ghcr.io/utensils/comfyui-nix:latest-${gpuArchitecture}";
        ports = [ "127.0.0.1:8188:8188" ];

        devices = [
          "/dev/kfd"
          "/dev/dri"
        ];

        volumes = [
          "/var/lib/comfyui:/data:rw"
          "/etc/passwd:/etc/passwd:ro"
          "${pkgs.libdrm}/share/libdrm/amdgpu.ids:/opt/amdgpu/share/libdrm/amdgpu.ids:ro"
        ];

        extraOptions = [
          "--security-opt=label=disable" # Required for Podman to allow GPU access in some configs
        ];

        autoStart = false; # prevent from waiting during rebuild
        environment = lib.mkIf cfg.useOutdatedAmdGpuWorkaround {
          "HSA_OVERRIDE_GFX_VERSION" = "11.0.0";
          "ROC_ENABLE_PRE_VEGA" = "1"; # Required for Polaris cards

          # optimize memory on older cards to prevent OOM
          "PYTORCH_HIP_ALLOC_CONF" = "garbage_collection_threshold:0.8,max_split_size_mb:512";
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/comfyui 0755 root root -"
    ];

    # system.activationScripts.startHeavyService = {
    #   deps = [ "setupSecrets" ];
    #   text = ''
    #     # The service name is usually 'docker-SERVICE' or 'podman-SERVICE'
    #     ${pkgs.systemd}/bin/systemctl start --no-block docker-my-heavy-service.service
    #   '';
    # };
  };
}

# #########################################################
#                                                        #
# Nixtra Configuration                                   #
# OS based on NixOS                                      #
#                                                        #
# - Repository: https://github.com/quarterstar/nixtra    #
# - Documentation: https://github.com/quarterstar/nixtra #
#                                                        #
# * The configuration previously defined in              #
#   `profile-settings.nix` was automatically converted   #
#   to its equivalent `options` as seen in this file, as #
#   of Sep. 6th 2025.                                    #
##########################################################

{ config, lib, pkgs, settings, ... }:

let
  # Shorthand for the main configuration set
  cfg = config.nixtra;

  # Duplicated because overlays do not affect
  # the module option namespace.
  mkNixtraOption = type: default: description:
    lib.mkOption { inherit type default description; };

  # Helper to define simple, common options
  #mkNixtraOption = type: default: description:
  #  lib.mkOption { inherit type default description; };

  # Type for wm.taskbar.apps elements
  taskbarAppType = lib.types.submodule {
    options = {
      program = lib.mkOption {
        type = lib.types.str;
        description = lib.mdDoc "The command to execute for the application.";
      };
      icon = lib.mkOption {
        type = lib.types.str;
        description = lib.mdDoc "The icon file name (e.g., 'terminal.png').";
      };
    };
  };

  # Type for git.autoPush/autoClone.repositories elements
  gitRepoType = lib.types.submodule {
    options = {
      service = lib.mkOption {
        type = lib.types.str;
        description = lib.mdDoc "The Git service (e.g., 'github', '*').";
      };
      owner = lib.mkOption {
        type = lib.types.str;
        description =
          lib.mdDoc "The repository owner (e.g., 'quarterstar', '*').";
      };
      repository = lib.mkOption {
        type = lib.types.str;
        description =
          lib.mdDoc "The repository name (e.g., 'opsec-index', '*').";
      };
    };
  };

  # Type for tor.aliases.programs elements
  torAliasProgramType = lib.types.submodule {
    options = {
      program = lib.mkOption {
        type = lib.types.str;
        description = lib.mdDoc "The program path to alias through torsocks.";
      };
      hardAlias = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc ''
          Whether to create a hard alias (e.g., replace the original binary)
          or a shell alias.
        '';
      };
      systemWideInstall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc ''
          Whether to install the alias system-wide (requires `hardAlias` to be true).
        '';
      };
    };
  };

  # Type for tor.services
  torProxyServiceType = lib.types.submodule {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc "Whether to enable this proxy service.";
      };
      tag = lib.mkOption {
        type = lib.types.str;
        description = lib.mdDoc "A unique tag for the proxy service.";
      };
      port = lib.mkOption {
        type = lib.types.port;
        description = lib.mdDoc "The port the proxy service will listen on.";
      };
    };
  };

  # Type for microsocks.services
  microsocksProxyServiceType = lib.types.submodule {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc "Whether to enable this proxy service.";
      };
      tag = lib.mkOption {
        type = lib.types.str;
        description = lib.mdDoc "A unique tag for the proxy service.";
      };
      port = lib.mkOption {
        type = lib.types.port;
        description = lib.mdDoc "The port the proxy service will listen on.";
      };
      entries = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            type = lib.mkOption {
              type = lib.types.enum [ "socks5" "http" ];
              description =
                lib.mdDoc "The type of upstream proxy (socks5 or http).";
            };
            address = lib.mkOption {
              type = lib.types.str;
              description = lib.mdDoc "The address of the upstream proxy.";
            };
            port = lib.mkOption {
              type = lib.types.port;
              description = lib.mdDoc "The port of the upstream proxy.";
            };
          };
        });
        default = [ ];
        description =
          lib.mdDoc "List of upstream proxies for microsocks to use.";
      };
    };
  };

  # Type for flatpak.sources
  flatpakSourceType = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description =
          lib.mdDoc "The name of the Flatpak repository (e.g., 'flathub').";
      };
      source = lib.mkOption {
        type = lib.types.str;
        description = lib.mdDoc
          "The URL or path to the Flatpak repository file (.flatpakrepo).";
      };
      allowForUser = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description =
          lib.mdDoc "Whether this source is allowed for user installations.";
      };
    };
  };

  # Type for flatpak.apps
  flatpakAppType = lib.types.submodule {
    options = {
      app = lib.mkOption {
        type = lib.types.str;
        description = lib.mdDoc
          "The Flatpak application ID (e.g., 'com.cakewallet.CakeWallet').";
      };
      url = lib.mkOption {
        type = lib.types.nullOr lib.types.str; # Can be null if source is used
        default = null;
        description = lib.mdDoc ''
          Direct URL to the .flatpakRef file for installation.
          If `source` is set, this is ignored.
        '';
      };
      source = lib.mkOption {
        type = lib.types.nullOr lib.types.str; # Can be null if url is used
        default = null;
        description = lib.mdDoc ''
          The name of the configured Flatpak source (e.g., 'flathub')
          from which to install the app.
        '';
      };
      user = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc ''
          Whether to install the Flatpak app at the user level (`true`)
          or system-wide (`false`).
        '';
      };
    };
  };

  # Type for scheduledTasks
  scheduledTaskType = lib.types.submodule {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc "Whether to enable this scheduled task.";
      };
      name = lib.mkOption {
        type = lib.types.str;
        description = lib.mdDoc "A unique name for the scheduled task.";
      };
      time = lib.mkOption {
        type = lib.types.str; # cron format or systemd.time(7) format
        description = lib.mdDoc
          "The time or schedule for the task (e.g., '23:00', 'hourly').";
      };
      action = lib.mkOption {
        type = lib.types.str;
        description =
          lib.mdDoc "The command or script to execute for the task.";
      };
    };
  };

  # Type for env.programs
  envProgramType = lib.types.submodule {
    options = {
      program = lib.mkOption {
        type = lib.types.str;
        description = lib.mdDoc "The program to configure.";
      };
      envVars = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description =
          lib.mdDoc "Environment variables specific to this program.";
      };
    };
  };

  # Type for sops.keys elements
  sopsKeyType = lib.types.submodule {
    options = {
      neededForUsers = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc ''
          Whether this SOPS key is needed for user decryption (e.g., for
          passwords).
        '';
      };
      # Add other potential key-specific options here if needed in the future
    };
  };

  # Type for sops.templates elements
  sopsTemplateType = lib.types.submodule {
    options = {
      content = lib.mkOption {
        type = lib.types.lines;
        description = lib.mdDoc ''
          The content of the template. Use `''${sops.placeholder."your/key/path"}`
          to insert the decrypted SOPS secret.
        '';
      };
      # Add other potential template-specific options here if needed in the future
    };
  };

  sshHostType = lib.types.submodule ({ name, ... }: {
    options = {
      hostNames = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description =
          "A list of hostnames for this SSH host. Can be an IP address or a host name";
      };

      publicKeySecret = lib.mkOption {
        type = lib.types.str;
        description = ''
          The path to the secret containing the public key for this host.
          This would typically be a path within a secrets management system.
        '';
      };

      user = mkNixtraOption lib.types.str "user"
        "The default user that programs using SSH should connect to.";
      profile = mkNixtraOption lib.types.str ""
        "The name of the Nixtra profile that should be associated with this SSH host, if it is using Nixtra. An empty string means that it is not a Nixtra host";
    };
  });
in {
  options.nixtra = {
    user = {
      username =
        mkNixtraOption lib.types.str "user" "Username of the main user.";
      uid = mkNixtraOption lib.types.int 1001 "User ID for the main user.";

      declarativeUsers = {
        enable = mkNixtraOption lib.types.bool true
          "Whether to enable declarative user management.";
        passwordSecret = mkNixtraOption lib.types.str "password"
          "SOPS secret name for the user's password.";
      };

      desktop = mkNixtraOption (lib.types.enum [ "flagship-hyprland" "empty" ])
        "flagship-hyprland" (lib.mdDoc ''
          Available options: `flagship-hyprland`, `empty`.
          Use `empty` if you want to cherry-pick individual desktop configs in home.nix.
        '');

      shell = {
        backend = mkNixtraOption (lib.types.enum [ "zsh" "fish" "bash" ]) "zsh"
          (lib.mdDoc "Available options: `zsh` (recommended), `fish`, `bash`.");

        environmentVariables =
          mkNixtraOption (lib.types.attrsOf lib.types.str) { }
          "Environment variables to set at the end with the shell. This may be needed for some environment variables like `SSH_ASKPASS`.";
      };

      browser = lib.mkOption {
        type = lib.types.str;
        default = "lynx";
        description = "The preferred browser for applications to use.";
      };

      terminal = mkNixtraOption lib.types.str "kitty"
        "The preferred terminal for applications to use.";

      editor = mkNixtraOption lib.types.str "nvim"
        "The preferred editor for applications to use.";

      groups = mkNixtraOption (lib.types.listOf lib.types.str) [
        "wheel" # sudo/doas
        "docker" # For using docker on userspace
        "libvirtd" # For managing VMs on userspace
        "video"
        "render" # For access to GPU functions by user; required for OpenCL by some installation
      ] "List of groups the user should be a member of.";
    };

    nix = {
      caches = mkNixtraOption (lib.types.listOf lib.types.str) [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org/"
        "https://chaotic-nyx.cachix.org/"
        "https://cachix.cachix.org"
        "https://nix-gaming.cachix.org/"
        "https://hyprland.cachix.org"
        # "https://nixpkgs-wayland.cachix.org"
        # "https://devenv.cachix.org"
      ] "List of Nix binary caches to use.";
      cachesKeys = mkNixtraOption (lib.types.listOf lib.types.str) [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        # "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        # "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ] "List of public keys for Nix binary caches.";
    };

    hardware = {
      laptop =
        mkNixtraOption lib.types.bool false "Whether the PC is a laptop.";

      cpu = lib.mkOption {
        type = lib.types.str;
        description = lib.mdDoc ''
          The CPU manufacturer used by the PC.
          Available options: `amd`, `intel`
        '';
      };

      gpu = lib.mkOption {
        type = lib.types.str;
        description = lib.mdDoc ''
          The GPU manufacturer used by the PC.
          Available options: `amd`, `nvidia`
        '';
      };
    };

    disk = {
      ssd = mkNixtraOption lib.types.bool true
        "Whether the disk being used is an SSD.";

      partitions = {
        boot = lib.mkOption {
          type = lib.types.str;
          description = "The path to the boot partition.";
          example = "/dev/disk/by-uuid/12CE-A600";
        };
        storage = lib.mkOption {
          type = lib.types.str;
          description = "The path to the storage partition.";
          example = "/dev/disk/by-uuid/75f7fad7-0065-49a1-950c-ba5913eeae83";
        };
      };

      encryption = {
        enable = mkNixtraOption lib.types.bool true
          "Whether to use Full Disk Encryption.";
        decryptedRootDevice = lib.mkOption {
          type = lib.types.str;
          description = "The path to the decrypted root device.";
          example = "/dev/disk/by-uuid/ce341f6f-8daf-43d0-a034-901c93654118";
        };
      };
    };

    memory = {
      swap = {
        enable =
          mkNixtraOption lib.types.bool true "Whether to use swap memory.";
        zswap = mkNixtraOption lib.types.bool true
          "Whether to compress swap with zswap.";
        size = mkNixtraOption lib.types.int (8 * 1024)
          "The size of the swap partition.";
      };

      zram = {
        enable = mkNixtraOption lib.types.bool true
          "Whether to compress memory with zram.";
      };
    };

    system = {
      kernel =
        mkNixtraOption (lib.types.enum [ "standard" "security" "gaming" ])
        "security" (lib.mdDoc
          "The Linux kernel variant to use. Choose `standard` for the normal kernel, `security` for enhanced hardening measures, and `gaming` for performance optimizations.");

      timezone = {
        auto = mkNixtraOption lib.types.bool true
          "Whether to set the timezone by default. If set to true, `config.nixtra.timezone.default` will be ignored.";
        default = mkNixtraOption lib.types.str "America/New_York"
          "The geographical location that the timezone should be configured for.";
      };
      locale = mkNixtraOption lib.types.str "en_US.UTF-8"
        "The languages localization to use.";
      version =
        mkNixtraOption lib.types.str "25.11" "The version of the NixOS system.";
      initialVersion = mkNixtraOption lib.types.str "25.05"
        "The initial version the NixOS system was installed on.";

      filesystem =
        mkNixtraOption lib.types.str "btrfs" "The filesystem to use.";
      supportedFilesystems = mkNixtraOption (lib.types.listOf lib.types.str) [
        "btrfs"
        "ext4"
        "ntfs"
      ]
        "The filesystems the system should support. The necessary kernel modules for them are automatically installed.";

      nur = mkNixtraOption lib.types.bool true
        "Whether to use the NixOS User Repository, a community repository for Nix packages.";

      nixDirectories = mkNixtraOption (lib.types.listOf lib.types.str) [
        "modules"
        "presets"
        "profiles/${settings.profile}"
      ] (lib.mdDoc
        "Directories with `.nix` files that should be parsed, validated, and formatted automatically by Nixtra rebuild system.");
    };

    screen = {
      width = mkNixtraOption lib.types.int 1920 "Screen width in pixels.";
      height = mkNixtraOption lib.types.int 1080 "Screen height in pixels.";
    };

    display = {
      enable =
        mkNixtraOption lib.types.bool true "Whether to enable graphical output";

      server = mkNixtraOption (lib.types.enum [ "wayland" "none" ]) "wayland"
        (lib.mdDoc "Available options: `wayland`, `none`.");

      themeType = mkNixtraOption (lib.types.enum [ "dark" "light" "" ]) "dark"
        (lib.mdDoc "Available options: `dark`, `light`, `''`.");
    };

    desktop = {
      enable = mkNixtraOption lib.types.bool true
        "Whether to enable desktop environment configuration.";

      startupPrograms = mkNixtraOption (lib.types.listOf lib.types.str) [ ]
        "List of programs to launch on startup.";

      wallpaper = {
        directory = mkNixtraOption lib.types.str "$HOME/Wallpapers"
          "Directory where wallpapers are stored.";
        preference = mkNixtraOption lib.types.str ""
          "Preferred wallpaper path relative to the wallpaper directory. If not set, a random one will be used.";
        extensions =
          mkNixtraOption (lib.types.listOf lib.types.str) [ "png" "jpg" "gif" ]
          "File extensions to look for in the wallpaper directory.";
        switchInterval = mkNixtraOption lib.types.int (120 * 60)
          "Seconds after which wallpaper should be switched. Default: 2 hours (120 minutes).";
      };

      languages = mkNixtraOption (lib.types.listOf lib.types.str) [ "en" ]
        "The language keyboard layouts to use in desktop environments.";

      keybind = {
        numpadCompatibility = mkNixtraOption lib.types.bool false
          "Whether to replace Numpad keybinds with keys compatible with most keyboards.";
      };

      topbar = {
        enable =
          mkNixtraOption lib.types.bool true "Whether to enable the top bar.";
      };

      theme = {
        gtk = {

        };

        qt = {
          package = mkNixtraOption lib.types.package pkgs.utterly-nord-plasma
            "The package containing the Qt theme";
          selection = mkNixtraOption lib.types.str "Utterly-Nord" (lib.mdDoc
            "The name of a theme provided in the `share/Kvantum` directory of it.");
        };
      };

      taskbar = {
        enable = mkNixtraOption lib.types.bool true
          "Whether to enable the bottom taskbar.";
        apps = lib.mkOption {
          type = (lib.types.listOf taskbarAppType);
          #default = [ ];
          description = "List of applications to add to the bottom taskbar.";
          example = [
            {
              program = "${pkgs.kitty}/bin/kitty";
              icon = "terminal.png";
            }
            {
              program = "${pkgs.xfce.thunar}/bin/thunar";
              icon = "file-manager.png";
            }
            {
              program = "${pkgs.kitty}/bin/kitty ${pkgs.lunarvim}/bin/lunarvim";
              icon = "lunarvim.png";
            }
            {
              program = "${pkgs.librewolf}/bin/librewolf";
              icon = "librewolf.png";
            }
            {
              program = "${pkgs.freetube}/bin/freetube";
              icon = "freetube.png";
            }
            {
              program = "tor-browser-clearnet";
              icon = "tor-browser-clearnet.png";
            }
            {
              program = "tor-browser-proxy";
              icon = "tor-browser-proxy.png";
            }
            {
              program = "tor-browser";
              icon = "tor-browser.png";
            }
            {
              program = "${pkgs.kdePackages.okular}/bin/okular";
              icon = "okular.png";
            }
            {
              program = "${pkgs.virt-manager}/bin/virt-manager";
              icon = "vm.png";
            }
            {
              program = "${pkgs.openboard}/bin/OpenBoard";
              icon = "openboard.png";
            }
            {
              program = "${pkgs.krita}/bin/krita";
              icon = "krita.png";
            }
            {
              program = "${pkgs.keepassxc}/bin/keepassxc";
              icon = "keepassxc.png";
            }
          ];
        };
        iconSize = mkNixtraOption lib.types.int 38
          "Size of icons in the bottom taskbar (e.g., 50 for 50x50).";
      };

      programs = mkNixtraOption (lib.types.listOf envProgramType) [
        {
          program = "ssh";
          envVars = { TERM = "xterm-256color"; };
        }
        {
          program = "lxappearance";
          envVars = { GDK_BACKEND = "x11"; };
        }
      ] "List of programs and their specific environment variables.";

      mimeapps =
        mkNixtraOption (lib.types.attrsOf (lib.types.listOf lib.types.str)) { }
        "A mapping of MIME types to preferred default applications (.desktop file names).";
    };

    audio = {
      enable = mkNixtraOption lib.types.bool true "Whether to enable audio.";

      backend =
        mkNixtraOption (lib.types.enum [ "pipewire" "pulseaudio" "none" ])
        "pipewire" (lib.mdDoc
          "Available audio backends: `pipewire`, `pulseaudio`, `none`.");
    };

    network = {
      dns = mkNixtraOption (lib.types.listOf lib.types.str) [
        "94.140.14.14" # AdGuard
        "84.200.69.80" # DNS.Watch
        "91.239.100.100" # UncensoredDNS (primary)
        "89.233.43.71" # UncensoredDNS (secondary)
        "8.26.56.26" # Comodo (primary)
        "8.20.247.20" # Comodo (secondary)
      ] (lib.mdDoc ''
        List of DNS servers to use ONLY if VPN is disabled. These are some standard DNS servers that provide privacy.
        Do not set "127.0.0.53" here if systemd-resolved is enabled.
      '');
      fallbackDns =
        mkNixtraOption (lib.types.listOf lib.types.str) [ "1.1.1.1" "8.8.8.8" ]
        "List of DNS servers to use as fallback ONLY if VPN is disabled.";
    };

    kernel = {
      enableNonfreeFirmware = mkNixtraOption lib.types.bool false
        "Whether to install and enable non-free firmware. May be needed for things like wireless networking.";
      extraPackages = mkNixtraOption (lib.types.listOf lib.types.package) [ ]
        "List of additional kernel module packages to install";
    };

    security = {
      autoUpdate = mkNixtraOption lib.types.bool true
        "Whether to enable automatic system updates.";
      gc = mkNixtraOption lib.types.bool true
        "Whether to enable automatic garbage collection.";
      networking = mkNixtraOption lib.types.bool true
        "Whether to enable general networking capabilities for the system.";
      replaceSudoWithDoas = mkNixtraOption lib.types.bool true
        "Whether to replace `sudo` command with a more lightweight alternative (`doas`).";

      fhsCompatibilityMode = mkNixtraOption lib.types.bool false
        "Whether to have compatibility with apps that use the standard Linux FHS. (Populates `/bin` and `/usr/bin`, allows running unpatched dynamic binaries.)";

      kernel = {
        aggressivePanic = mkNixtraOption lib.types.bool true
          "Whether to panic immediately on any detected failure or potential vulnerabiltiy exploitation.";
        veryAggressivePanic = mkNixtraOption lib.types.bool true
          "Whether to panic immediately on any potential failures, including subtle warnings.";
        mitigateCommonVulnerabilities = mkNixtraOption lib.types.bool true
          "Whether to mitigate common CPU vulnerabilities across various architectures.";
        enforceDmaProtection = mkNixtraOption lib.types.bool true
          "Whether to enforce runtime DMA protection. (May interfere with common devices.)";
        requireSignatures = mkNixtraOption lib.types.bool true
          "Whether to allow only signed kernel modules. (May break Nvidia or VBox drivers.)";
        encryptMemory = mkNixtraOption lib.types.bool true
          "Whether to encrypt physical memory using architecture-specific solutions.";
      };

      nmConnectionRouterDnsExceptions =
        mkNixtraOption (lib.types.listOf lib.types.str) ([ "lo" "docker0" ]
          ++ (if cfg.security.vpn.enable && cfg.security.vpn.type
          == "mullvad" then
            [ "wg0-mullvad" ]
          else
            [ ])) (lib.mdDoc ''
              NetworkManager connections for which DNS configuration from the router
              SHOULD be used, bypassing custom DNS config.nixtra.
            '');

      firewall = {
        enable =
          mkNixtraOption lib.types.bool true "Whether to enable the firewall.";
        allowedTCPPorts = mkNixtraOption (lib.types.listOf lib.types.port) [
          80
          443
          1935
          8080
          53
          51820
          22
        ] "List of TCP ports to allow through the firewall.";
        allowedUDPPorts =
          mkNixtraOption (lib.types.listOf lib.types.port) [ 8080 51820 53 ]
          "List of UDP ports to allow through the firewall.";
      };

      virtualization = mkNixtraOption lib.types.bool false
        "Whether to enable virtualization (e.g., KVM, QEMU).";
      scanning = mkNixtraOption lib.types.bool true
        "Whether to enable Intrusion Detection System with Suricata.";
      aliases = mkNixtraOption lib.types.bool true
        "Whether to enable aliases for commands such as `rm` to prevent accidental data loss.";
      appimage = mkNixtraOption lib.types.bool true
        "Whether to enable running programs packed into the AppImage file format.";
      unpatchedBinaries = mkNixtraOption lib.types.bool true
        "Whether to allow running unpatched dynamic binaries.";
      secureboot =
        mkNixtraOption lib.types.bool true "Whether to enable secure boot.";
      disableUsbStorage =
        mkNixtraOption lib.types.bool false "Whether to disable USB storage";
      protectUsbStorage = mkNixtraOption lib.types.bool true
        "Whether to apply special security measures for connected USB devices.";
      protectBoot = mkNixtraOption lib.types.bool true
        "Whether to protect the kernel with boot related parameters.";
      protectKernel =
        mkNixtraOption lib.types.bool true "Whether to protect the kernel.";
      impermanence = mkNixtraOption lib.types.bool false (lib.mdDoc ''
        Whether to use the NixOS Impermanence mechanism.
        Will only work if `config.nixtra.system.filesystem` is set to `btrfs`.
      '');

      apparmor = {
        enable =
          mkNixtraOption lib.types.bool true "Whether to enable AppArmor.";
        rescueBootEntry = mkNixtraOption lib.types.bool true
          "Whether to add an auxiliary boot entry in case you get locked out of your system because of AppArmor. Strongly recommended.";
      };

      siem = {
        zeek = {
          enable = mkNixtraOption lib.types.bool true
            "Whether to enable the Zeek service.";
          interface = lib.mkOption {
            type = lib.types.str;
            description = "The interface Zeek should listen on.";
          };
        };

        wazuh = {
          enable = mkNixtraOption lib.types.bool true
            "Whether to enable the Wazuh service.";
        };
      };

      vpn = {
        enable = mkNixtraOption lib.types.bool false
          "Whether to enable the VPN configuration.";
        type =
          mkNixtraOption (lib.types.enum [ "mullvad" "wireguard" ]) "mullvad"
          "The type of VPN to configure.";

        dnsLeakPrevention = {
          dnsLeakTest = mkNixtraOption lib.types.bool true
            "Whether to do a DNS leak test upon successful VPN connection.";
          nmConnectionRouterDnsExceptions = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = ''
              List of NetworkManager connection names for which router-provided
              DNS settings should NOT be ignored.
            '';
          };
        };

        wireguard = {
          addresses = mkNixtraOption (lib.types.listOf lib.types.str) [ ]
            "List of IP addresses for the WireGuard interface.";
          privateKey = mkNixtraOption lib.types.str "vpn/wireguard/private_key"
            "SOPS path to WireGuard private key.";
          publicKey = lib.mkOption {
            type = lib.types.str;
            description = "WireGuard public key.";
          };
          endpointAddress = lib.mkOption {
            type = lib.types.str;
            description = "WireGuard endpoint IP address or hostname.";
          };
          endpointPort =
            mkNixtraOption lib.types.port 51820 "WireGuard endpoint UDP port.";
        };
      };

      firejail = {
        enable = mkNixtraOption lib.types.bool true
          "Whether to enable Firejail for application sandboxing.";

        disabledProfiles = mkNixtraOption (lib.types.listOf lib.types.str) [ ]
          "Profiles for programs that should not be used by default.";
      };

      excludedClipboardPrograms =
        mkNixtraOption (lib.types.listOf lib.types.str)
        [ "x-kde-passwordManagerHint" ] (lib.mdDoc ''
          Applications whose clipboard content should be ignored by clipboard listeners
          (e.g., password managers).
        '');
      closeOnSuspend = {
        enable = mkNixtraOption lib.types.bool true
          "Whether to close applications when suspending the PC.";
        applications = mkNixtraOption (lib.types.listOf lib.types.str) [
          "firefox"
          "librewolf"
          "tor-browser"
          "freetube"
        ] "List of application names to close when suspending.";
      };
      replaceCoreutilsWithUutils = mkNixtraOption lib.types.bool true
        "Whether to replace GNU coreutils with uutils (Rust coreutils).";
      permittedInsecurePackages =
        mkNixtraOption (lib.types.listOf lib.types.str) [
          # "python-2.7.18.8"
        ] (lib.mdDoc ''
          List of permitted insecure packages. These may only be used under a profile
          whose `networking` is disabled.
        '');
      permittedUnfreePackages =
        mkNixtraOption (lib.types.listOf lib.types.str) [
          "steam"
          "steam-original"
          "steam-run"
          "steam-unwrapped"
          "drawio" # Unfree since 24.11; 24.05 contains old build
          "volatility3"
          "davinci-resolve"
        ] (lib.mdDoc ''
          List of explicitly permitted unfree packages.
        '');

      extraUsers = mkNixtraOption (lib.types.listOf lib.types.str) [ ]
        "Extra users to define. Very limited functionality. Primarily used to store critical data safely.";

      sops = {
        keys = lib.mkOption {
          description =
            "The paths of the SOPS keys defined in your SOPS config.";

          default = { "password" = { neededForUsers = true; }; };

          example = {
            "vpn/wireguard/private_key" = { neededForUsers = true; };
          };
        };
        templates = lib.mkOption {
          description = "SOPS templates to use.";
          default = { };

          #example = {
          #"vpn/wireguard/private_key".content = "''${sops.placeholder."vpn/wireguard/private_key"}''";
          #};
        };
      };
    };

    performance = {
      preventOutOfMemoryPanic = mkNixtraOption lib.types.bool true
        (lib.mdDoc "Whether to prevent OOM kernel panic with earlyoom.");
      useHugePages = mkNixtraOption lib.types.bool false
        "Whether to use larger memory pages than the default 4 KB page size; reduce TLB misses, improve memory throughput. Disabled by default because it may disable physical KASLR for certain machines.";
      monitorServices = mkNixtraOption lib.types.bool true
        "Whether to monitor and manage systemd services with monit service.";
      monitorDeviceHealth = mkNixtraOption lib.types.bool true
        "Whether to monitor device health and send critical notifications with smartd service.";
      watchdog = mkNixtraOption lib.types.bool true
        "Whether to enable watchdog, which checks if a serious problem has occurred and automatically restarts if so.";
    };

    anonymity = {
      spoofMacAddress = mkNixtraOption lib.types.bool true
        "Whether to spoof the MAC address of network interfaces.";
      spoofMiscIdentifiers = mkNixtraOption lib.types.bool false
        "Whether to spoof various miscellaneous system identifiers.";
    };

    networks = {
      tornet = {
        enable = mkNixtraOption lib.types.bool false
          "Whether to enable the Onion network subnet (Tor).";
        subnet = mkNixtraOption lib.types.str "192.168.2.0/24"
          "The subnet to use for the Tor network.";
      };
    };

    browser = {
      closeOnSuspend = mkNixtraOption lib.types.bool true
        "Whether to close the browser after waking up from suspend for security reasons.";
      useBetterfox = mkNixtraOption lib.types.bool true
        "Whether to apply Betterfox configuration to supported browsers.";
    };

    git = {
      signCommits = mkNixtraOption lib.types.bool true
        "Whether to sign Git commits by default.";
      randomizeCommitDate = mkNixtraOption lib.types.bool true
        "Whether to randomize Git commit dates.";

      proxy = {
        enable = mkNixtraOption lib.types.bool true
          "Whether to enable a proxy for Git operations.";
        address = mkNixtraOption lib.types.str "socks5://127.0.0.1:9152"
          "The address of the Git proxy.";
      };

      autoPush = {
        enable = mkNixtraOption lib.types.bool true
          "Whether to enable automatic Git pushes.";
        time = mkNixtraOption lib.types.str "00:00"
          "The scheduled time for automatic Git pushes.";
        repositories = mkNixtraOption (lib.types.listOf gitRepoType) [{
          service = "*";
          owner = "*";
          repository = "*";
        }] "List of repositories to automatically push. Use '*' for all.";
      };

      autoClone = {
        enable = mkNixtraOption lib.types.bool true
          "Whether to enable automatic Git clones.";
        repositories = mkNixtraOption (lib.types.listOf gitRepoType) [
          {
            service = "github";
            owner = "quarterstar";
            repository = "opsec-index";
          }
          {
            service = "github";
            owner = "quarterstar";
            repository = "opsec-infra";
          }
        ] "List of repositories to automatically clone.";
      };
    };

    ssh = {
      enable = mkNixtraOption lib.types.bool true "Whether to enable SSH";
      permitRootLogin = mkNixtraOption lib.types.bool false
        "Whether to permit root login (insecure)";
      hosts = mkNixtraOption (lib.types.attrsOf sshHostType) { }
        "Configuration for SSH hosts";
      rootAuthorizedKeySecrets =
        mkNixtraOption (lib.types.listOf lib.types.str) [ ]
        "List of SOPS secret names for connecting to user with authorized SSH keys";
      userAuthorizedKeySecrets =
        mkNixtraOption (lib.types.listOf lib.types.str) [ ]
        "List of SOPS secret names for connecting to root with authorized SSH keys";
      useTerminalForPassword = mkNixtraOption lib.types.bool true
        "Whether to use terminal for getting SSH passphrase.";
    };

    i2p = {
      enable =
        mkNixtraOption lib.types.bool false "Whether to enable I2P (i2pd)";
    };

    tor = {
      enable =
        mkNixtraOption lib.types.bool true "Whether to enable Tor services.";
      isRunMoneroNode = mkNixtraOption lib.types.bool true
        "Whether to listen to ports for hidden services if running a local Monero node.";
      aliases = {
        enable = mkNixtraOption lib.types.bool true
          "Whether to enable Tor aliases for programs.";
        programs = mkNixtraOption (lib.types.listOf torAliasProgramType) [
          # { program = "${pkgs.freetube}/bin/freetube"; }
          # { program = "com.cakewallet.CakeWallet"; }
        ] (lib.mdDoc "List of programs to run over Tor (requires torsocks).");
      };
      services = mkNixtraOption (lib.types.listOf torProxyServiceType) [
        {
          enable = true;
          tag = "git";
          port = 9152;
        }
        {
          enable = true;
          tag = "yellow";
          port = 9150;
        }
        {
          enable = true;
          tag = "cakewallet";
          port = 9151;
        }
      ] "List of Tor hidden services to configure.";
    };

    microsocks = {
      enable = mkNixtraOption lib.types.bool true
        "Whether to enable Microsocks proxy.";
      services = mkNixtraOption (lib.types.listOf
        microsocksProxyServiceType) [{ # Used by Tor Browser yellow flavor (see 04-hardening.md)
          enable = true;
          tag = "yellow";
          port = 1080;
          entries = [
            {
              type = "socks5";
              address = "127.0.0.1";
              port = 9150;
            } # Tor proxy
            {
              type = "socks5";
              address = "72.37.217.3";
              port = 4145;
            } # Public anonymous proxy (supports HTTPS)
          ];
        }] "List of Microsocks proxy services to configure.";
    };

    miniflux = {
      enable = mkNixtraOption lib.types.bool true
        "Whether to enable the Miniflux RSS reading frontend.";
      adminSecret = mkNixtraOption lib.types.str "miniflux/admin"
        "SOPS secret key name for admin environment credentials.";
    };

    shell = {
      enable = mkNixtraOption lib.types.bool true
        "Whether to enable custom shell configurations.";
      ai_integration = mkNixtraOption lib.types.bool false
        "Whether to enable AI integration for Kitty terminal (code complete, chat).";
      aliases = mkNixtraOption (lib.types.attrsOf lib.types.str) {
        rm = "${pkgs.trash-cli}/bin/trash";
        neofetch = "${pkgs.fastfetch}/bin/fastfetch";
        ls = "${pkgs.eza}/bin/eza";
        cat = "${pkgs.bat}/bin/bat";
        df = "${pkgs.duf}/bin/duf";
        lsblk = "${pkgs.dysk}/bin/dysk";
        #tree = "${pkgs.lstr}/bin/lstr";
        find = "${pkgs.fd}/bin/fd";
        ps = "${pkgs.procs}/bin/procs";
        cp = "${pkgs.xcp}/bin/xcp";
        du = "${pkgs.dust}/bin/dust";
        diff = "${pkgs.difftastic}/bin/difft";
        grep = "${pkgs.ripgrep}/bin/rg";
        vim = "${pkgs.neovim}/bin/nvim";
        #top = "${pkgs.bottom}/bin/bottom";
      } "A mapping of shell command aliases.";
      fastfetchOnStartup = mkNixtraOption lib.types.bool true
        "Whether to show information similar to neofetch on shell startup.";
      commands = {
        enable = mkNixtraOption lib.types.bool true
          "Whether to enable special Nixtra commands (e.g., `nixtra-screenshot`).";
        prefix = mkNixtraOption lib.types.str "nixtra" (lib.mdDoc ''
          The prefix to use for Nixtra commands (e.g., `nixtra` for `nixtra-screenshot`).
          WARNING: changing this may break raw configs that expect it to be the default.
          It is advised that you do not modify it.
        '');
      };
    };

    flatpak = {
      enable = mkNixtraOption lib.types.bool false
        "Whether to enable Flatpak support.";
      sources = mkNixtraOption (lib.types.listOf flatpakSourceType) [{
        name = "flathub";
        source = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        allowForUser = true;
      }] "List of Flatpak repositories to configure.";
      apps = lib.mkOption {
        type = lib.types.listOf flatpakAppType;
        example = [
          {
            app = "com.cakewallet.CakeWallet";
            url =
              "https://github.com/cake-tech/cake_wallet/releases/download/v4.25.0/Cake_Wallet_v4.25.0_Linux_Beta.flatpak";
            user = false;
          }
          {
            app = "com.stremio.Stremio";
            source = "flathub";
            user = false;
          }
          {
            app = "network.bisq.Bisq";
            source = "flathub";
            user = false;
          }
          {
            app = "com.valvesoftware.Steam";
            source = "flathub";
            user = false;
          }
          {
            app = "net.lutris.Lutris";
            source = "flathub";
            user = false;
          }
          {
            app = "org.vinegarhq.Sober";
            source = "flathub";
            user = false;
          }
          {
            app = "com.discordapp.Discord";
            source = "flathub";
            user = false;
          }
        ];
        description = lib.mdDoc ''
          List of Flatpak applications to install.
          Note: User level installation not recommended because of common
          execvp permission denied error; do system-wide installation instead
          by setting "user" to `false`.
        '';
      };
    };

    searx = {
      secretPath = lib.mkOption {
        type = lib.types.str;
        description = "SOPS path to searx secret key";
      };
    };

    scheduledTasks = mkNixtraOption (lib.types.listOf scheduledTaskType) [ ]
      "List of scheduled system tasks.";

    debug = {
      persistJournalLogs = mkNixtraOption lib.types.bool false
        "Whether to persist journal logs across reboots.";

      doVerboseKernelLogs = mkNixtraOption lib.types.bool false
        "Whether to allow the kernel to make extraneous logs.";
    };

    fun = {
      mysteriousFortuneCookie =
        mkNixtraOption lib.types.bool true "Would You Like To Have Some Fun?";
    };
  };
}

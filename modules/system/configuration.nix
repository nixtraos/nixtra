{ config, settings, profilePreset, profileSettings, timestamp, lib, pkgs
, unstable-pkgs, inputs, ... }:

let
  # Note for beginners:
  # 'pkgs' here would be the result of importing the nixpkgs
  # expression, typically with a specific system and overlays applied.
  # e.g., pkgs = import <nixpkgs> { system = "x86_64-linux"; };

  currentTimestamp = lib.readFile
    "${pkgs.runCommand "timestamp" { } "date +%Y-%m-%d_%H-%M-%S > $out"}";

  modulesPath = "${inputs.nixpkgs}/nixos/modules";

  nixtraLib = import ../lib/lib.nix { inherit config lib pkgs; };

  # Stage 1: Preset integration
  # Stage 2: Profile integration
  basicNixtra = (import ../../presets/${profileSettings.preset}/profile.nix {
    inherit pkgs config;
  }) // (import ../../profiles/${settings.profile}/profile.nix {
    inherit pkgs config;
  });

  # Stage 3: Reflection
  reflectedNixtra = basicNixtra // (import ./reflection.nix {
    nixtra = basicNixtra;
    inherit pkgs;
  });

  # Stage 4: Logical validation
  nixtra = reflectedNixtra
    // (import ./validation.nix { nixtra = reflectedNixtra; });
in {
  imports = [
    inputs.home-manager.nixosModules.default

    # Overlays
    ../overrides/overrides.nix

    # Nixtra options and profile
    ../options.nix

    # Profile-based configuration
    (../../profiles + ("/" + settings.profile) + "/configuration.nix")
    (../../presets + ("/" + profileSettings.preset) + "/configuration.nix")

    # Parts
    ./cpu/cpu.nix
    ./gpu/gpu.nix
    ./audio/pipewire.nix
    ./audio/pulseaudio.nix
    ./server/wayland.nix
    ./shell/backend/backend.nix
    ./fs/fs.nix
    ./memory/memory.nix
    ./desktop/desktop.nix
    ./peripherals/peripherals.nix
    ./patches/patches.nix

    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # Security
    ./security/security.nix
    # FIXME: https://github.com/NixOS/nixpkgs/issues/360616
    #"${modulesPath}/profiles/hardened.nix" # NixOS security hardening
    "${inputs.nix-mineral}/nix-mineral.nix" # Complementary defaults for hardening for ones missed by security.nix and hardened.nix

    # Performance
    ./performance/performance.nix

    # Networks
    ./networks/tornet.nix

    # Settings-based imports

    # Shell
    ./shell/commands/commands.nix
    ./shell/aliases.nix

    # Other
    ./fonts.nix

    ./services/services.nix

    ./extra/extra.nix
  ];

  config = {
    _module.args = { inherit nixtraLib; };

    # Set the options provided by the user's profile
    inherit nixtra;

    nix = {
      settings = {
        # Enable Flakes
        experimental-features = [ "nix-command" "flakes" ];
        auto-optimise-store = true; # May make rebuilds longer but less size
        substituters = config.nixtra.nix.caches;
        trusted-public-keys = config.nixtra.nix.cachesKeys;
        #use-xdg-base-directories = true;
        warn-dirty = false;
        keep-outputs = true;
        keep-derivations = true;
        #restrict-eval = true;
      };
      optimise.automatic = true;
      package = pkgs.nixVersions.latest;
    };

    # https://www.reddit.com/r/NixOS/comments/1ompdwi/make_the_nix_daemon_nice_to_keep_your_system
    systemd.services.nix-daemon.serviceConfig = {
      Nice = lib.mkForce 15;
      IOSchedulingClass = lib.mkForce "idle";
      IOSchedulingPriority = lib.mkForce 7;
    };

    # Enable NUR
    # NUR for unstable channel(s) is considered a security risk in Nixtra, so it remains disabled.
    #nixpkgs.overlays = # [ inputs.zeek-nix.overlays.default ] ++
    #  lib.optionals config.nixtra.system.nur [ inputs.nur.overlays.default ];

    # Save configurations from old generations
    # Not currently supported by Flakes
    #system.copySystemConfiguration = true;

    # "Unsafe" packages
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg)
      config.nixtra.security.permittedUnfreePackages;
    nixpkgs.config.permittedInsecurePackages =
      if !config.nixtra.security.networking then
        config.nixtra.security.permittedInsecurePackages
      else
        [ ];

    # Enable docker containers support
    virtualisation.docker.enable =
      lib.mkIf config.nixtra.security.virtualization true;
    virtualisation.libvirtd.enable =
      lib.mkIf config.nixtra.security.virtualization true;

    # Define default shell for all users globally
    users.defaultUserShell = pkgs.${config.nixtra.user.shell.backend};

    # Enable networking
    networking.wireless.enable = false;
    networking.networkmanager.enable =
      lib.mkIf config.nixtra.security.networking true;
    networking.networkmanager.ethernet.macAddress =
      lib.mkIf config.nixtra.anonymity.spoofMacAddress "random";

    # networking.hosts = {
    #   "127.0.0.1" = [ "localhost" profileSettings.hostname ];
    #   "::1" = [ "localhost" profileSettings.hostname ];
    # };

    # Spoof network host ID
    # MAY cause issues with ZFS
    # Causes issue with geoclue and other services
    networking.hostId =
      lib.mkIf config.nixtra.anonymity.spoofMiscIdentifiers "00000000";

    # The DNS servers to use
    networking.nameservers =
      lib.mkIf (!config.nixtra.security.vpn.enable) config.nixtra.network.dns;
    services.resolved.fallbackDns =
      lib.mkIf (!config.nixtra.security.vpn.enable) config.nixtra.network.dns;

    # Enable debug symbols for NixOS packages
    # to make them easier to troubleshoot
    environment.enableDebugInfo = true;

    # Set system's name
    networking.hostName = if profileSettings.useHostnameProfilePrefix then
      "${profileSettings.hostname}-${settings.profile}"
    else
      profileSettings.hostname;

    # Set timezone
    time.timeZone = if !config.nixtra.system.timezone.auto then
      config.nixtra.system.timezone
    else
      null;
    services.automatic-timezoned.enable = config.nixtra.system.timezone.auto;

    # Select internationalisation properties.
    i18n.defaultLocale = config.nixtra.system.locale;

    # Make users immutable (declarative)
    users.mutableUsers = !config.nixtra.user.declarativeUsers.enable;

    # TOD
    programs.dconf.enable = true;

    # Ensure the system has common libraries for proprietary software, if needed.
    programs.nix-ld.enable = config.nixtra.security.unpatchedBinaries;

    environment.systemPackages = with pkgs; [
      nixfmt-classic # Nix formatter
      nixd # Nix language server
    ];

    programs.appimage = if config.nixtra.security.appimage then {
      enable = true;
      binfmt = true; # Enable binary format support
    } else
      { };

    xdg = {
      portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      };
    };

    # Configure home manager
    home-manager = {
      extraSpecialArgs = {
        inherit nixtraLib;
        inherit settings;
        inherit profileSettings;
        inherit inputs;
        inherit unstable-pkgs;
      };
      useGlobalPkgs = true;
      users = {
        "user" = import ../userspace/base/user.nix;
        "root" = import ../userspace/base/root.nix;
      }; # // (builtins.listToAttrs (map (username: {
      #  name = username;
      #  value = import ../userspace/base/custom-user.nix {
      #    inherit username;
      #    inherit settings;
      #  };
      #}) config.nixtra.security.extraUsers));

      # Automatically fix collisions
      backupFileExtension = "hm.backup.${currentTimestamp}";

      sharedModules = [
        (import ../options.nix)
        (import ./desktop/flagship-hyprland/options.nix)
      ];
    };

    # Define a user account.
    users.users = {
      ${config.nixtra.user.username} = {
        inherit (config.nixtra.user.uid)
        ;
        isNormalUser = true;
        extraGroups = config.nixtra.user.groups;
        linger = true;

        hashedPasswordFile = lib.mkIf config.nixtra.user.declarativeUsers.enable
          config.sops.secrets."${config.nixtra.user.declarativeUsers.passwordSecret}".path;
      };
    } // (builtins.listToAttrs (map (username: {
      name = username;
      value = { isNormalUser = true; };
    }) config.nixtra.security.extraUsers));

    # This option defines the first version of NixOS you have installed on this particular machine,
    # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
    # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
    system.stateVersion =
      config.nixtra.system.initialVersion; # Did you read the comment?
  };
}

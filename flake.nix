{
  description = "Nixtra Configuration Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-hyperfagia.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable-hyperfagia.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-lvm.url = "github:nixos/nixpkgs/2fbfb1d73d239d2402a8fe03963e37aab15abe8b";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };

    #nur = {
    #  url = "github:nix-community/nur";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Advanced NixOS security hardening
    nix-mineral = {
      url = "github:cynicsketch/nix-mineral";
      flake = false;
    };

    # Secure Boot for NixOS
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #impermanence.url = "github:nix-community/impermanence";

    # For creating ISOs with fine-grained control
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Generating Nix derivations for various languages smoothly
    dream2nix = {
      url = "github:nix-community/dream2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # zeek-nix = {
    #   url = "github:hardenedlinux/zeek-nix/main";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    systems = {
      url = "github:nix-systems/default";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative NeoVim
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    comfyui.url = "github:utensils/comfyui-nix";

    # wayscriber.url = "github:devmobasa/wayscriber";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      flake-parts,
      home-manager,
      sops-nix,
      lanzaboote,
      disko,
      nixos-generators,
      systems,
      git-hooks,
      nix-ld,
      nixpkgs-lvm,
      dream2nix,
      ...
    }:
    let
      hostSettings = import ./settings.nix;
      hostProfileSettings = import (./profiles + ("/" + hostSettings.profile) + "/settings.nix");
      hostName =
        if hostProfileSettings.useHostnameProfilePrefix then
          "${hostProfileSettings.hostname}-${builtins.replaceStrings [ "/" ] [ "-" ] hostSettings.profile}"
        else
          hostProfileSettings.hostname;

      otherProfiles = builtins.filter (profile: profile != hostSettings.profile) (
        builtins.attrNames (builtins.readDir ./profiles)
      );

      mkNixtraSystem =
        profile:
        let
          profileSettings = import (./profiles + ("/" + profile) + "/settings.nix");
          unstableNixpkgsConfig = import ./modules/system/unstable-configuration.nix;
        in
        nixpkgs.lib.nixosSystem {
          system = profileSettings.arch;
          modules = [
            ./modules/system/configuration.nix
            home-manager.nixosModules.default
            sops-nix.nixosModules.sops
            lanzaboote.nixosModules.lanzaboote
            disko.nixosModules.disko
            #impermanence.nixosModules.impermanence
          ];
          specialArgs = {
            settings = hostSettings;
            inherit profileSettings;
            inherit hostName;
            inherit inputs;
            unstable-pkgs = nixpkgs-unstable.legacyPackages.${profileSettings.arch};

            # TEMP (FIXME)
            lvm-pkgs = nixpkgs-lvm.legacyPackages.${profileSettings.arch};
          };
        };

      forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ];

      systems = import systems;

      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:

        {
          devShells.default = pkgs.mkShell { packages = [ pkgs.bashInteractive ]; };
          checks.pre-commit-check = git-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixfmt-rfc-style.enable = true;
            };
          };

          formatter =
            let
              hookConfig = config.checks.pre-commit-check.config;
              inherit (hookConfig) package configFile;
              script = ''
                ${pkgs.lib.getExe package} run --all-files --config ${configFile}
              '';
            in
            pkgs.writeShellScriptBin "pre-commit-run" script;

          apps.create-iso = {
            type = "app";
            program =
              let
                buildScript = pkgs.writeShellScriptBin "build-iso" ''
                  set -e
                  echo "Building NixOS ISO..."

                  ${pkgs.nix}/bin/nix build .#nixosConfigurations."${hostName}-installer".config.system.build.isoImage

                  echo "Copying generated ISO to current directory..."

                  cp result/iso/*.iso ./nixtra-installer.iso
                  chmod +w ./nixtra-installer.iso

                  echo "Done! Generated: ./nixtra-installer.iso"
                '';
              in
              "${buildScript}/bin/build-iso";
          };
        };

      flake = {
        nixosConfigurations = {
          ${hostName} = mkNixtraSystem hostSettings.profile;

          "${hostName}-installer" = nixpkgs.lib.nixosSystem {
            system = hostProfileSettings.arch;
            modules = [
              "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"

              # add any extra packages and an install script into the ISO
              (
                { pkgs, ... }:
                {
                  environment.systemPackages = [
                    (pkgs.writeScriptBin "nixtra-install" (builtins.readFile ./net/install.sh))
                    pkgs.bash
                    pkgs.systemd
                    pkgs.coreutils
                    pkgs.git
                    pkgs.e2fsprogs
                    pkgs.util-linux
                    pkgs.parted
                    pkgs.gnused
                    pkgs.btrfs-progs
                    pkgs.zfs
                    pkgs.cryptsetup
                  ];
                }
              )
            ];

            specialArgs = {
              settings = hostSettings;
              inherit hostProfileSettings hostName inputs;
              unstable-pkgs = nixpkgs-unstable.legacyPackages.${hostProfileSettings.arch};
              lvm-pkgs = nixpkgs-lvm.legacyPackages.${hostProfileSettings.arch};
            };
          };
        }
        // builtins.listToAttrs (
          map (profile: {
            name = "profile-${profile}";
            value = mkNixtraSystem profile;
          }) otherProfiles
        );
      };
    };

  nixConfig = {
    accept-flake-config = true;
    warn-dirty = false;
  };
}

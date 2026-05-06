{
  nixtraLib,
  config,
  stdenv,
  lib,
  pkgs,
  ...
}:

let
  inherit (nixtraLib.command) createCommand;
in
{
  imports = [
    ./sandman/sandman.nix
    ./ai/ai.nix
  ];

  config = lib.mkIf config.nixtra.shell.commands.enable {
    environment.systemPackages = [
      (pkgs.callPackage ./screenshot.nix { inherit config createCommand; })
      (pkgs.callPackage ./rebuild.nix {
        inherit config createCommand nixtraLib;
      })
      (pkgs.callPackage ./restore-backup.nix { inherit config createCommand; })
      (pkgs.callPackage ./build-iso.nix { inherit config createCommand; })
      (pkgs.callPackage ./check.nix { inherit config createCommand; })
      (pkgs.callPackage ./record.nix { inherit config createCommand; })
      (pkgs.callPackage ./unlock.nix { inherit config createCommand; })
      (pkgs.callPackage ./update.nix { inherit config createCommand; })
      (pkgs.callPackage ./upgrade.nix { inherit config createCommand; })
      (pkgs.callPackage ./regen-hardware.nix { inherit config createCommand; })
      (pkgs.callPackage ./regen-bootloader.nix {
        inherit config createCommand;
      })
      (pkgs.callPackage ./fix-bootloader.nix { inherit config createCommand; })
      (pkgs.callPackage ./enter-temp-fhs.nix { inherit config createCommand; })
      (pkgs.callPackage ./create-iso.nix { inherit config createCommand; })
      (pkgs.callPackage ./hide-git-dir.nix { inherit config createCommand; })
      (pkgs.callPackage ./unhide-git-dir.nix { inherit config createCommand; })
      (pkgs.callPackage ./clean.nix { inherit config createCommand; })
      (pkgs.callPackage ./check-cliphist-store.nix {
        inherit config createCommand;
      })
      (pkgs.callPackage ./check-security-status.nix {
        inherit config createCommand;
      })
      (pkgs.callPackage ./theme/reset-cursor.nix {
        inherit config createCommand;
      })
    ]
    ++ (import ./rebuild-other.nix {
      inherit
        pkgs
        config
        createCommand
        nixtraLib
        lib
        ;
    });
  };
}

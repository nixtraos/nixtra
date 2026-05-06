{
  config,
  pkgs,
  createCommand,
  ...
}:

createCommand {
  name = "build-iso";
  command = # bash
    ''
      set -e
      ORIGINAL_DIR="$(pwd)"
      trap 'cd "$ORIGINAL_DIR"' EXIT

      cd /etc/nixos
      git add --intent-to-add .
      cd - > /dev/null
      rm -rf /home/${config.nixtra.user.username}/.cache/nix/tarball-cache # Workaround fix for root ownership permission issue
      mkdir -p /etc/nixos/dist
      nix build /etc/nixos#nixosConfigurations.iso.config.system.build.images.iso -o /etc/nixos/dist/iso
    '';
}

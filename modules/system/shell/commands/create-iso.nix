{ config, createCommand, ... }:

createCommand {
  name = "create-iso";
  buildInputs = [ ];

  command = # bash
    ''
      nix build /etc/nixos#nixosConfigurations.default.config.system.build.isoImage
    '';
}

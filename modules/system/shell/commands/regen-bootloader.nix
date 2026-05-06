{ createCommand, ... }:

createCommand {
  name = "regen-bootloader";
  buildInputs = [ ];

  command = # bash
    ''
      NIXOS_INSTALL_BOOTLOADER=1 /nix/var/nix/profiles/system/bin/switch-to-configuration boot
    '';
}

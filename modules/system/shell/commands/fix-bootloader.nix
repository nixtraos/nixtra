{ config, createCommand, ... }:

createCommand {
  name = "fix-bootloader";
  buildInputs = [ ];

  command = # bash
    ''
      ${config.nixtra.shell.commands.prefix}-regen-hardware
      ${config.nixtra.shell.commands.prefix}-rebuild
      ${config.nixtra.shell.commands.prefix}-regen-bootloader
    '';
}

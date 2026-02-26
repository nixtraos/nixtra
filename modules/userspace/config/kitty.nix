{ config, pkgs, ... }:

{
  programs.kitty.extraConfig = if config.nixtra.shell.ai_integration then
    let kittyai = (pkgs.callPackage ../../../packages/kittyai/default.nix { });
    in ''
      map kitty_mod+i kitten bash -c "exec ${kittyai}/bin/kittyai"

      map ctrl+shift+f send_text all \x1b[1;6F
    ''
  else
    "";
}

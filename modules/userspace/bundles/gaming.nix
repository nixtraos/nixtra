{ config, ... }:

{
  imports = [
    ../pkgs/games/lutris.nix
    #../pkgs/games/minecraft/prismlauncher.nix
    #../pkgs/games/roblox.nix
    #../pkgs/emu/cemu.nix
    ../pkgs/emu/ryujinx.nix
    ../pkgs/emu/wine.nix
    ../pkgs/emu/bottles.nix
    ../pkgs/browser/librewolf/default.nix
    ../pkgs/browser/chatgpt-container.nix
    ../pkgs/notes/zettlr.nix
    ../pkgs/audio/alsa.nix
    ../pkgs/virt/virtualbox.nix
    ../pkgs/virt/virtualbox.nix
    ../pkgs/performance/gamescope.nix
    ../pkgs/performance/gamemode.nix
    ../pkgs/social/dissent.nix
  ];
}

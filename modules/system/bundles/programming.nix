{ inputs, ... }:

{
  imports = [
    # Modules
    ../pkgs/cli/git.nix
    ../pkgs/cli/network.nix
    ../pkgs/cli/stats.nix
    ../pkgs/cli/sysadmin.nix
    ../pkgs/cli/git.nix
    ../pkgs/cli/eza.nix
    ../pkgs/signing/gnupg.nix
    ../pkgs/file/gparted.nix
    ../pkgs/file/thunar.nix
    ../pkgs/proxy/torsocks.nix
    ../pkgs/virt/podman.nix
    ../pkgs/nix/devenv.nix

    # Services
    ../services/ollama.nix
    ../services/flatpak.nix
  ];
}

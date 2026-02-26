# TODO

A list of things that need to be done for Nixtra. When an entry is completed, it shall be scratched off the list and erased in the next release.

## Features

**Configuration**

- Implement `rkhunter` scans to `nixtra-check-security-status`
- Secure core systemd services with sandboxing
- Implement Graylog, Zeek, Wazuh
- Ask user in the installer for screen display resolution / fetch it automatically for apps that need to know it
- Ask user in the installer for VPN / Proxy configuration
- Reduce the number of pre-installed packages in profiles (to make the distro more lightweight)
- Use impermanence
- Wipe clipboard history on shutdown
- Implement automatic config backup for each generation with encryption
- Add game to play during primary installation step
- Notify user when a shell alias is used for the first time
- Fix NVIDIA module Nix error
- Automatically play soothing music when learning or using a learning-related program (e.g., Anki, Okular)
- Mitigate prefix hijacks targetting guard nodes with vulnerable BGP by verifying RPKI presence
- eDNS
- Add IMA support
- Add GUI widgets for the control functions with AGS or some other toolkit
- Implement Numpad compatibility
- Implement pywal
- Add two focus modes in Hyprland
  - External focus mode: select a set of workspaces to remain visible and hide the other ones; push them to an invisible special workspace / scratchpad
  - Internal focus mode: select a program in the current workspace to focus on; hide all the other programs in the workspace; push them to an invisible special workspace / scratchpad
  - Restore the programs to their original workspaces when disabling either one

**Core**

- RISC-V security modules
  - QEMU & Spike patch for memory tagging

## Bugfixes

- Fix zsh taking too long to load Oh My Zsh
- Investigate https://github.com/NixOS/nixpkgs/issues/82851

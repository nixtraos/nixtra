<div align="center">
<img width="64" height="64" src="./shared-assets/icons/logo.png">
<br>

<!--<img src="https://badgen.net/github/stars/quarterstar/nixtra">-->
<!--<img src="https://badgen.net/github/watchers/quarterstar/nixtra">-->
<!--<img src="https://badgen.net/github/license/quarterstar/nixtra">-->
<!--<br>-->

<h2>❄️Nixtra❄️</h2>

<p align="center">
    <b>⚡ Your Supercharged NixOS Distro</b>
</p>

<p align="center">
    <img style="border-radius: 15px;" src="./assets/demos/sample.jpg">
</p>

<p float="left">
  <img src="./assets/demos/sample.jpg" width="200" />
  <img src="./assets/demos/sample.jpg" width="200" />
  <img src="./assets/demos/sample.jpg" width="200" />
</p>

**[<kbd> <br> Install <br> </kbd>][Install]** 
**[<kbd> <br> Usage <br> </kbd>][Usage]** 
**[<kbd> <br> Configure <br> </kbd>][Configure]** 
**[<kbd> <br> Contribute <br> </kbd>][Contribute]**

---

<p align="center">
    <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png" width="400">
</p>

<p align="center">
    <a href="https://github.com/ryan4yin/nix-config/stargazers">
        <img alt="Stargazers" src="https://img.shields.io/github/stars/serpentian/AlfheimOS?style=for-the-badge&logo=starship&color=C9CBFF&logoColor=D9E0EE&labelColor=302D41">
    </a>
    <a href="https://nixos.org/">
        <img src="https://img.shields.io/badge/NixOS-25.05-informational.svg?style=for-the-badge&logo=nixos&color=F2CDCD&logoColor=D9E0EE&labelColor=302D41">
    </a>
</p>

</div>

## About Project

Nixtra is **your** Linux distribution that is fully declarative, immutable, reproducible, modular, ephemeral, mostly stable, tailored to your specific needs but without heavy bloat, extremely extensive with security measures, equipped with sane defaults, and packaged with a pleasing environment with a myriad of utilities. This is what I wanted when I started learning NixOS, and I hope that if you try this, you too will realize that it is truly something great.

Nixtra is a fully-featured, hardened and extensible that focuses on anonymity, privacy and security *while still being eye candy*. It is designed to:

- Provide an ideal environment for gaming, programming, research, security analysis, virtualization, and more.
- Give the ability to switch between different profiles in within a single user, each designated a different role, to prevent distractions and straighten my workflow.
- Harden the security of any system with minimal compromises and implement sane defaults for opsec.
- Be easily understandable, customizable and extensible by other NixOS users interested in the use and/or further development of the configuration.
- Patch out the weird quirks that come with using NixOS.
- Make NixOS easier to use and customize.

Why NixOS? Because impure system state should be volatile and the rest should be declarative and immutable. Or because of my security paranoia :p

## Table of Contents

- [Features](#features)
- [Security Features](#security-practices)
- [Donate](#donate)
- [User Accounts](#user)
- [Configuration](#configuration)
- [Project Structure](#project-structure)
- [See Also](#see-also)
- [Credits](#credits)

## Features

- Pre-installed, beautifully-riced Hyprland environment.
- Utilities for day-to-day use, including screenshotting, recording, etc.
- Extensive and thorough security measures, covering many threat models.
- Aggressive performance and memory optimizations.
- Helpful documentation.
- Different flavors of profiles and presets configured with a variety of packages to fulfill your needs.
- A, lot, and I mean a **LOT** of pre-baked fixes for common NixOS issues and annoyances.
- High-level configuration system.

## Security Features

Some example security features (which can be toggled on or off) Nixtra employs are:

**Subtleties**

- [Tor browser uses a unique flavor-based system with separate Tor browsers.](./docs/01-usage.md##)
- Incorporated into the kernel are strict configurations for kernel parameters, with a combination of various NixOS resources, including `nix-mineral`, the `hardening` nixpkgs profile, and other standard setups.
- Most core systemd services are sandboxed.
- All permitted insecure packages may only be used under a profile with no networking enabled.
- `rm` is replaced with an alias of `trash` to prevent accidental permanent file deletion and many other aliases are included.
- Critical and untrusted application-level programs are encapsulated by a firejail wrapper to sandbox them and restrict their scope and permissions.
- Clipboard's buffer is cleared 10 seconds after being written, regardless of the application modifying it or the data being pasted.
- A set of sensitive applications like Tor Browser is pre-configured to automatically close upon the PC receiving a suspend signal.
- Sound access is disabled for Tor Browser and other sensitive applications.
- Certain software like Git are configured to route all traffic through Tor for anonymity.
- Many core components utilities (like gnu coreutils) are replaced with mature Rust-written equivalents which patch out many security vulnerabilities often found in C programs, without breaking userspace.
- Features like commits in Git use a randomized date to make it harder to pinpoint someone's timezone.
- ...and more

**Industry Standards**

- Network Intrusion Detection System (IDS) with Suricata
- Host-level outbound connection control with OpenSnitch
- Host intrusion detection with Wazuh (fork of OSSEC)
- Brute force attack prevention with Fail2ban
- Detailed network protocol analysis with Zeek
- System auditing with Auditd
- Nix Firewall
- Log aggregation & alerting with Graylog (SIEM system)
- ...and more

For a complete list and elaboration for the above, view [SECURITY.md](SECURITY.md).

## Donate

I have put months of research into the development of this project (and most of my sanity). If you wish to support me financially and have the means to do so, feel free to check out the donation methods listed [here](https://www.quarterstar.tech/pages/donate.html).

## Software

Nixtra comes with software bundles for:

- Programming
- Web Development
- Security Researching
- Penetration Testing
- Reverse Engineering
- Gaming
- Virtualization
- Multimedia Applications
- Social Media Applications
- ...and more

## User Accounts

The Nixtra environment is intended to be used as a single-user system. A default `user` account configuration is provided. However, the user may pick a profile based on their software and hardware needs.

## Configuration

Nixtra is a single-user NixOS configuration, but the user may have multiple profiles. It follows the philosophy of "one system, many configurations." You could have a profile for each machine you own, or maybe compose different ones for a single running system. It is entirely up to you how you will make use of Nixtra's modular profile system.

For more information, refer to the [configuration page](./docs/02-configuration.md).

## Project Structure

- `profiles`: configuration for the [profiles mechanism](./docs/02-configuration.md).
- `config`: non-nix configurations for applications. [Read More](./docs/01-configuration.md)
- `firejail`: configuration files for [hardening user and system applications](./docs/03-hardening.md) with firejail.
- `modules/system`: all system-level services, applications and configurations.
- `modules/userspace`: all the installed userspace applications and configurations.

## See Also

- [My Nix-related Articles](https://www.quarterstar.tech/pages/articles)

## Credits

Nixtra wouldn't have been possible without publicly-available royalty-free assets and open source projects 🙌

**Assets**

- [Wallpaper](https://steamcommunity.com/sharedfiles/filedetails/?id=3323190978)
- [Startup Sound Effect](https://pixabay.com/sound-effects/soft-startup-sound-269291)
- [Chat Notification Sound Effect](https://pixabay.com/sound-effects/new-notification-07-210334)

**Code**

All of the works below have been heavily modified to accommodate the needs of this operating system and add new functionality.

- [github:stelcodes/nixos-config](https://github.com/stelcodes/nixos-config/blob/main/packages/overlay.nix) - Overlay for firejail
- [gist.github:raffaem](https://gist.github.com/raffaem/bb9c35c6aab663efd7a0400c33d248a1) - Record module for waybar
- [github:siddrs/tokyo-night-sddm](https://github.com/siddrs/tokyo-night-sddm) - Base config for SDDM theme
- [github:Sly-Harvey/NixOS](https://github.com/Sly-Harvey/NixOS) - Various scripts for Hyprland
- [gitlab:Zaney/zaneyos](https://gitlab.com/Zaney/zaneyos) - Base config for [fastfetch](https://gitlab.com/Zaney/zaneyos/-/blob/main/modules/home/fastfetch/default.nix), [cava](https://gitlab.com/Zaney/zaneyos/-/blob/main/modules/home/cava.nix)
- [gitlab:usmcamp0811/dotfiles](https://gitlab.com/usmcamp0811/dotfiles) - Examples for templates, building NixOS ISOs
- [gist.github:theprojectsomething](https://gist.github.com/theprojectsomething/6813b2c27611be03e67c78d936b0f760) & [github:AmadeusWM/dotfiles-hyprland](https://github.com/AmadeusWM/dotfiles-hyprland) - Rice for Firefox
- [github:chiraag-nataraj/firejail-profiles](https://github.com/chiraag-nataraj/firejail-profiles): A curated set of Firejail profiles for common applications
- [github:wochap/nix-config](https://github.com/wochap/nix-config): Configuration for [FHS Compatibility Mode](https://github.com/wochap/nix-config/blob/main/modules/nixos/system/fhs-compat/default.nix)

Some small utilities and scripts may have credits directly embedded into their respective files in Nixtra's codebase.

PSA: If you are a contributor to Nixtra, giving credits isn't only important to uphold values and maintain legitimacy, but also to trace back the origin of the code if any subsequent issues arise!

## License

All Nixtra code included in this repository is licensed under the terms of the [GNU Affero General Public License](LICENSE). Further, all text including, but not limited to:

- Documentation in the `./docs` directory;
- GitHub Wiki entries; and
- GitHub Pages associated with Nixtra

are licensed under [CC-BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.en), unless otherwise stated explicitly by the respective author of the software and text.

All third-party open source projects that are subject to copyleft obligations have their license included in the [licenses](licenses) directory.

## Liability Disclaimer

THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY
APPLICABLE LAW.  EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT
HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY
OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE.  THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM
IS WITH YOU.  SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF
ALL NECESSARY SERVICING, REPAIR OR CORRECTION.

[Install]: ./docs/00-installation.md
[Usage]: ./docs/01-usage.md
[Configure]: ./docs/02-configuration.md
[Contribute]: ./CONTRIBUTING.md

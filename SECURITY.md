# Security

> [!IMPORTANT]
> Nixtra is open source software and its developers and contributors are in no way liable for any security vulnerabilities discovered in Nixtra's components, its packages or its dependencies.

## About Nixtra

### Security Programs, Features & Services

- Secure Boot: prevent bootkits, firmware rootkits, and evil maid attacks
- Full Disk Encryption: mitigate physical data theft
- zram: encrypt the system memory
- zswap: encrypt the swap file on the disk (disk memory); prevent cold boot attacks
- Impermanence: make configs, data, cache, etc on the filesystem ephemeral; reset on boot unless whitelisted (TODO)
- Hardened Linux Kernel: specially packaged kernel with security flags
- Strict Kernel Parameters: boot flags and sysctl flags for attack mitigation, network optimization, and attack surface reduction
- Sandboxed Core Systemd Services: mitigate attacks from critical systemd services that have root with systemd sandboxing
- Restricted USB Access with USBGuard: prevent usbkillers and unauthorized system tempering with usb-based attacks; filter connected devices
- DNS Leak Prevention: disable network access if dns leak with vpn or custom dns server is detected; block router dns fetching on dhcp level
- OpenSnitch: cherrypick allowed network connections from individuals applications; prevent telemetry, tracking, and data theft
- Nix firewall: filter incoming/outgoing tcp/udp connections, allowed and disallowed ports, and more
- fail2ban: detect login bruteforce attacks and block origin ips
- Automatic Security Audits
- Automatic, Unattended Security Upgrades
- SOPS-Nix: encrypt systems to prevent leakage to `/nix/store` during build time
- Immutable users: disallow modifying user permissions imperatively (declarative user configuration only)
- Firejail: userspace-level app sandboxing for pre-installed applications (lutris, librewolf, etc)
- AppArmor: kernel-level sandboxing for many applications (wip)
- Searx: metasearch engine (ensures search engine do not fingerprint input events or collect metadata); automatically used in pre-installed browsers like LibreWolf
- Wazuh (TODO)
- Zeek + Suricata (TODO)
- Graylog or Elastic Stack (TODO)
- Tor: multiple Tor Browser flavors with compartmentalized network traffic (distinct Tor instances), each for specific use cases
- Network Neighbor Index (NNI): Nixtra subsystem that monitors devices connected to the same network, checks their accessible ports, and determines whether the running services are vulnerable (TODO)

### Imperativity

Almost all of Nixtra's components are declared and managed by NixOS; however, certain aspects—specifically those related to initial disk setup—are done in an imperative way via the installer. This is done for two reasons, one being that using `disko` would make it very difficult to manage all permutations of disk installations (considering choice of filesystem, full disk encryption, and impermanence), and because most users will not have to repeat these steps more than once for any installation of a Nixtra system. If you want to use extra features for security like btrfs subvolumes in conjunction with impermanence, you will need to add your own code.

### Backwards Compatibility & Deprecation

In the case where a superior alternative to a current Nixtra solution for a problem is discovered, the following procedure based on a 2-release window cycle will take place:

If an option that exists in mainstream Nixtra is superceded, a warning shall appear in the following Nixtra release, and it is to be completely removed from the codebase two releases afterwards. The goal with this migration plan is to allow users to recursively update their system to the latest release, so that they get the patches from each one individually, without polluting upstream with deprecated functionality.

If an option is related to a security risk imposed by Nixtra, the same procedure as the one above follows, but instead of a warning, the user shall get a hard error.

## Information for Users

### Security Considerations

- Do NOT set your password or secrets in NixOS modules! Nix generates `.drv` files after building which may contain the password, allowing anyone to view it worldwide. Instead, either use SOPS or provide secrets to programs imperatively.

## Information for Contributors

Nixtra comes with a lot of packages pre-installed. As such, it is possible for a security vulnerability to be discovered in any of them at any time. Below is our standard procedure protocol and some tips to help us mitigate such scenarios.

### Guidelines

- If the vulnerability affects the specific version of the package, and a fixed version has not yet been released or added to the upstream Nixpkgs channel, please open an issue request specifically mentioning the problematic version.
- If a program becomes unmaintained or made obsolete by a successor, open an issue request describing your proposed alternative.
- If a security vulnerability is caused by Nixtra's code, send me a private e-mail with a PoC and ancillary information.

### Enhancements

- If you believe a program would greatly benefit from sandboxing, consider making a pull request to sandbox the program with firejail or any other supported containment solution.
    - If you believe that a program would benefit from being used over an anonymity network like Tor, consult the pre-existing Nixtra configuration to make it use that service and open a PR for it.

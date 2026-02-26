# Nixtra - Software

Nixtra comes packaged with a lot of software depending on the bundles you choose to use. One of the benefits we aim to give to our users is a curated set of pre-installed software for specific and discrete purposes. For instance, we provide one drawing app for general-purpose drawing (Krita), and one for infrastructure diagrams (draw.io).

These applications may come with small differences from one Nixtra desktop environment configuration to another, but the package set itself is generally idempotent.

Due to our security policy, any app you see below that is not open source does not come with any of our bundles, and must be explicitly installed in one's user profile. In addition, most of the programs below are sandboxed using our Firejail and AppArmor profiles. To learn more, refer to previous documentation.

In short, a software is added if it meets the following criteria:

0. Does the program have a reasonable security policy?
0. Who are the developers of the program?
0. Is the program open source?
0. How widespread is the program?
0. Is there a program with a similar purpose already in Nixtra?
0. If there is such a program, does this one do the job better or cover gaps?

Below is the curated list of software that comes with Nixtra and the purpose that each serves. There are a lot of miscellaneous programs in the OS, especially terminal utilities, so the list tries to cover the important ones.

## Curated Application List

### General Purpose

#### Emulation (& Compatibility Layers)

- WINE: Windows program compatibility layer
- Bottles: sandbox environment for WINE prefixes

#### Communication

- Element: Matrix client
- Dissent: Discord client

#### Browser

- LibreWolf: clearnet browsing
- Tor Browser: anonymous browsing & onion browsing (see Tor flavors for more info)

#### Text & Office

- LibreOffice: replacement for Microsoft Office

#### Notes

- Zettlr: markdown & LaTeX notes
- Planify: GUI TODO list

#### Music

- cmus: TUI audio player
- cava: terminal audio visualizer

#### Video Playing

- mpv: general video player
- vlc: secondary general video player
- FreeTube: open source and privacy-focused YouTube player

#### Reading

- Newsflash: RSS reader
- Kiwix: local wikipedia browsing
- Okular: PDF reader & other file formats

#### Drawing

- Krita: general drawing
- OpenBoard: whiteboard
- draw.io: infrastructure diagrams
- gromit-mpx: desktop overlay program for writing

#### AI

- Ollama: various open weight local models

### Password & Backup Management

- KeepassXC: offline password manager
- Cryptomator: client-side encryption tool for protecting files before they are sent to cloud

### Specialized

#### Programming

##### Markup Languages & Misc

These languages, build environments, etc come with preconfigured environments out-of-the-box.

- Python
- Java
- JavaScript (Node)
- C (GCC)
- C++ (GCC, CMake)
- Rust
- LaTeX

##### Editors, IDEs & Tools

- Git: repository management
- NeoVim: terminal-based editor
- Codium: VS code editor fork

##### Digital Logic Design

- Logisim Evolution: circuit design

#### Cybersecurity

##### Forensics

- mat2: metadata remover from various file formats
- binwalk: find hidden embedded files in binaries
- volatility: analyze RAM data

##### Reverse Engineering

- Ghidra: open source reverse engineering program developed by NSA

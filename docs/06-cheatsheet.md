# Nixtra- Cheatsheet

Congratulations for reaching this point! If you have installed Nixtra, that means you are ready to learn Nix more in-depth, which is a path that you will have to discover yourself. But to make the experience easier, below you will find a list of compiled information that you can reference any time you get confused.

I found that reading [this blog post](https://nixos-and-flakes-ja.hayao0819.com/nixos-with-flakes/nixos-with-flakes-enabled) and onward will explain some rudimentary concepts prety well, though that particular book is predominantly written in Japanese. You will find supplementary learning material below.

## Learning NixOS

**Documentation**

- [nix-book](https://saylesss88.github.io)
- [Zero to Nix](https://zero-to-nix.com)
- [NixOS Modules Lessons](https://nixos-modules.nix.xn--q9jyb4c/)
- [nix.dev](https://nix.dev/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [The Nix lectures](https://ayats.org/blog/nix-tuto-1#the-nix-lectures-part-1-introduction-and-language-basics)

**Videos**

- [The Nix Hour](https://youtube.com/playlist?list=PLyzwHTVJlRc8yjlx4VR4LU5A5O44og9in): Comprehensive deep-dive into the Nix language and NixOS systems.

**Reference**

- [MyNixOS](https://mynixos.com)
- [searchix](https://searchix.ovh)

## Package Reference Websites

## Misc Resources

## NixOS Flakes & Module System

<img src="https://repology.org/graph/map_repo_size_fresh.svg">

**Flakes**

`/etc/nixos/flake.nix`: The entrypoint for the flake, which is recognized and deployed when sudo nixos-rebuild switch is executed.
`/etc/nixos/flake.lock`: The automatically generated version lock file, which records the data sources, hash values, and version numbers of all inputs in the entire flake, ensuring system reproducibility.

**Parameters**

(Source: [https://nixos-and-flakes-ja.hayao0819.com/nixos-with-flakes/nixos-flake-and-module-system](https://nixos-and-flakes-ja.hayao0819.com/nixos-with-flakes/nixos-flake-and-module-system))

NixOS modules have five automatically generated, automatically injected, and declaration-free parameters provided by the module system:

- `lib`: A built-in function library included with nixpkgs, offering many practical functions for operating Nix expressions.
    - For more information, see [https://nixos.org/manual/nixpkgs/stable/#id-1.4](https://nixos.org/manual/nixpkgs/stable/#id-1.4).
- `config`: A set of all options' values in the current environment, which will be used extensively in the subsequent section on the module system.
- `options`: A set of all options defined in all Modules in the current environment.
- `pkgs`: A collection containing all nixpkgs packages, along with several related utility functions.
    - At the beginner stage, you can consider its default value to be `nixpkgs.legacyPackages."${system}"`, and the value of pkgs can be customized through the nixpkgs.pkgs option.
    - More precisely, it is the result of importing `nixpkgs` and storing it into a variable `pkgs`.
- `modulesPath`: A parameter available only in NixOS, which is a path pointing to [nixpkgs/nixos/modules](https://github.com/NixOS/nixpkgs/tree/nixos-25.05/nixos/modules).
    - It is defined in [nixpkgs/nixos/lib/eval-config-minimal.nix#L43](https://github.com/NixOS/nixpkgs/blob/nixos-24.11/nixos/lib/eval-config-minimal.nix#L43).
    - It is typically used to import additional NixOS modules and can be found in most NixOS auto-generated `hardware-configuration.nix` files.
    - For instance, it can be used inside a NixOS module to refer to the NixOS installation media module: `imports = [ (modulesPath + "/installer/cd‑dvd/installation‑cd‑minimal.nix") ];`

You *do not* have to explicitely put them in the function signature if you have the ellipsis `...`, which manages any arguments you do not use.

**`config` argument vs. `config` attribute**

(Source: [https://nix.dev/tutorials/module-system/deep-dive](https://nix.dev/tutorials/module-system/deep-dive))

The `config` argument is *not* the same as the `config` attribute:

- The `config` argument holds the result of the module system’s lazy evaluation, which takes into account all modules passed to evalModules and their imports.
- The `config` attribute of a module exposes that particular module’s option values to the module system for evaluation.

## NixOS Modules vs. Home Manager

(Source: [https://nixos-and-flakes-ja.hayao0819.com/nixos-with-flakes/start-using-home-manager](https://nixos-and-flakes-ja.hayao0819.com/nixos-with-flakes/start-using-home-manager))

- NixOS Modules: Install system core components and other software packages or configurations needed by all users. For instance, if you want a software package to continue working when you switch to the root user, or if you want a configuration to apply system-wide, you should install it using NixOS Modules.
- Home Manager: Use Home Manager for all other configurations and software.

## `nixpkgs` Repository Structure

**pkgs/**

- `pkgs/`: Contains the vast majority of package definitions.
    - Organized hierarchically by categories (e.g., `development`, `applications`, `tools`, etc.).
    - Packages typically reside in `pkgs/<category>/<sub>/.../<pkgname>/default.nix` or `package.nix`.
    - Naming conventions: lowercase file/directory names with hyphens (e.g. `all-packages.nix`, not camelCase).

- `pkgs/by-name/`: A name-based shortcut layout that maps package attribute names directly to file paths, bypassing category hierarchy.
    - Directory structure: uses a two-letter prefix for grouping (e.g. `pkgs/by-name/so/some-package/package.nix`).
    - Automatically included without needing to edit `all-packages.nix`.

- `pkgs/top-level/`: This area orchestrates how packages are composed via Nixpkgs’s fixed-point.
    - `default.nix`: The primary module that brings everything together, defining package sets and entrypoints.
    - `stage.nix`: Chains together different build stages (e.g., bootstrapping environments and cross-compilation support).

**lib/**

- `lib/`: Contains the standard library for internal and downstream usage.
    - Common modules include: `lib.strings`, `lib.lists`, `lib.path`, `lib.fetchers`, `lib.generators`, etc.
    - It offers utilities for string processing, path normalization, derivation generation, fetch helpers, and more.

**nixos/**

- `nixos/modules/`: Houses system modules that define NixOS behavior (e.g., services, system options).
    - Overlays customization is supported via user-defined overlays in configs, allowing override or extension of `pkgs`.

**Summary**

| Directory / File Path          | Purpose                                                  |
| ------------------------------ | -------------------------------------------------------- |
| `pkgs/`                        | Main package categories and definitions                  |
| `pkgs/by-name/`                | Flat, name-based package mapping for convenience         |
| `pkgs/top-level/*`             | Orchestration, Nixpkgs bootstrapping, fixed-point stages |
| `lib/`                         | Standard library of utility functions and helpers        |
| `NixOS/modules/`               | System modules (services, configuration options)         |
| `default.nix` (root)           | Main entry point for imports and overlays                |
| `CONTRIBUTING.md`, `ci/`, etc. | Guidelines, CI tooling, and test infrastructure          |

[1]: https://releases.nixos.org/nixpkgs/nixpkgs-17.03pre91233.8d8f57d/manual/index.html "Nixpkgs Contributors Guide"
[2]: https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/README.md "nixpkgs/pkgs/by-name/README.md at master · NixOS/nixpkgs · GitHub"
[3]: https://nixos.org/manual/nixpkgs/stable/index.html "Nixpkgs Reference Manual"
[4]: https://nixos.org/manual/nixpkgs "Nixpkgs Reference Manual"

## `pkgs` Functions

**pkgs.callPackage**

(Source: [https://nix.dev/tutorials/callpackage](https://nix.dev/tutorials/callpackage))

hello.nix
```nix
{ writeShellScriptBin }:
writeShellScriptBin "hello" ''
  echo "Hello, world!"
''
```

default.nix
```nix
let
  pkgs = import <nixpkgs> { };
in
pkgs.callPackage ./hello.nix { }
```

The argument `writeShellScriptBin` gets filled in automatically when the function in `hello.nix` is evaluated. For every attribute in the function's argument, `pkgs.callPackage` passes an attribute from the `pkgs` attribute set if it exists.

## Language Constructs

- `<entry>` (e.g. `<nixpkgs>`): a special path placeholder that represents the location of the `entry` repository in the Nix search path (`$NIX_PATH`)
    - For Nixpkgs, it is usually `/nix/var/nix/profiles/per-user/root/channels`

## Evaluation

**Configuration**

First, Nix gathers all `options` definitions from all modules. This gives it a complete picture of what can be configured. Then, it gathers all `config` definitions (including those wrapped in `lib.mkIf`) and merges them.

For example, when it encounters `lib.mkIf config.nixtra.audio.backend == "pipewire" { ... }`, it knows it needs the value of the `nixtra.audio.backend` option. It can determine this value based on its default value provided in `lib.mkOption` or any explicit assignment statements.

To better understand this, consider an example of circular dependencies: Nix is evaluating `modules/system/configuration.nix`. As part of this, it's trying to build the `imports` list. One line of `imports` contains the expression `(./audio + ("/" + config.nixtra.audio.backend) + ".nix")` To determine which file to import for audio, it needs the value of `config.nixtra.audio.backend`; however, the `config` argument in this module includes the configuration provided by the very modules it's trying to import. If `config.nixtra.audio.backend` is defined within one of the modules in the imports list (or if this module itself contributes to `nixtra.audio.backend`), then Nix needs to know `config.nixtra.audio.backend` to decide what to import, but `config.nixtra.audio.backend` can only be fully known after all modules (including the one being conditionally imported) are evaluated. This is a type of chicken and egg problem, and the only way to fix this is to make the import conditional.

**Phases**

Nix expressions are evaluated in two phases; evaluation time and build time.

Evaluation phase, which is done by the Nix interpreter, evaluates Nix expressions *lazily*. This means expressions are not evaluated when they are defined, but only when they are needed. For example, this happens when you explicitly access a value, when a package needs to be built, or when some computation requires it.

Consider the following example:

```nix
let
  x = throw "This will crash";
in
  42
```

This expression does not throw an error because `x` is never used, so it is *never* evaluated. During this phase, the interpreter processes expressions such as function calls, attribute lookups, string interpolations (like `"${pkgs.bash}/bin/bash"`), and derivation definitions. Importantly, derivations are only evaluated enough to describe what to build—for example, resolving their dependencies and build instructions—but not actually built yet.

Once the evaluation phase produces one or more derivations (the build instructions packaged as Nix expressions), Nix enters the build or realization phase. In other words, it knows what to build but has not yet.

This phase uses a special sandbox to ensure purity and reproducability. To see a real-world example of this in action, make your own derivation with `stdenv`, run a git clone command inside a build phase (shell code), and you will see that it fails to connect to the Internet because network access is restricted for build processes; furthermore, all of the following resources of the host are limited for derivations during realization:

- Access to the Internet (networking)
- Access to the Host File System (except the Nix store and explicitly allowed paths)
- Access to Environment Variables (restricted)
- Access to Devices
- Access to Sockets and IPC
- System Calls (depending on sandbox backend, e.g., sandboxfs and bubblewrap)

When you nix build, nix develop, etc., Nix realizes derivations into actual store paths. This includes downloading/building dependencies, running build scripts, etc. It also where `mkDerivation` fetches sources, compiles software, etc.

When you run the aforementioned commands, Nix takes the derivations and:

1. Downloads any required source files or dependencies
1. Executes build scripts (e.g., configure, make, ninja)
1. Installs the built artifacts into the Nix store
1. Produces the final outputs with fixed, immutable paths

## Nix Shell Commands

**nix-build**

Example:
```bash
nix-build '<nixpkgs/nixos>' -A config.system.build.toplevel
```

This is the command that builds Nix derivations — the low-level, reproducible build instructions.

- `<nixpkgs/nixos>`: This is a Nix expression path referring to a file inside the Nixpkgs repository, as explained in the Language Constructs section.
    - Specifically, `<nixpkgs/nixos>` points to: `$NIX_PATH/nixpkgs/nixos/default.nix`
    - This is the NixOS module system entry point, which sets up a full NixOS system configuration (not just a package).
- `-A config.system.build.toplevel`: This selects the specific attribute from the result of evaluating the Nix expression.
    - `-A` means "build this attribute"; that is, the attribute is a derivation.
    - `config` is the evaluated NixOS configuration (a huge attribute set).
    - `config.system.build.toplevel` is the actual derivation that builds the entire system closure (i.e. all packages, config files, systemd units, etc. needed for a NixOS system).
        - The `config.system.build.toplevel` derivation is generated by `nixpkgs/nixos/modules/system/activation/activation.nix`, specifically through a series of steps defined in various system-building functions.

This is the exact derivation that ends up being used by:

```bash
nixos-rebuild switch
```

It builds the full NixOS system you would boot into. In newer Nix syntax, this is identical to `nix build -f '<nixpkgs/nixos>' config.system.build.toplevel`.

## Case Scenarios

### Hunting Down Packages in the Nix Store

In Nix, packages installed on the system do not follow the standard Linux filesystem hierarchy, which makes it hard to track them down for newcomers. Thankfully, NixOS provides a set of utilities to traverse its special quirks, in the form of commands. This article focuses on such commands, and the motivation behind using them.

Before I begin, I need to get a few terms out of the way. A *derivation* is a build recipe for software. It consists of inputs and outputs. Outputs are what we will later discover to be directly connected to the software packages we install.

For the first scenario, suppose you are a programmer and have installed a library like `glm` on your NixOS system, which is a mathematical library for C/C++. If you do not understand what that means, imagine code that exists on your system as a package that you cannot directly run. Since it is not an executable, you cannot simply cheat your way by reading a symlink in your path (though specialized environment variables exist). So unless we want to run `find` in `/nix/store` and wait until the heat death of the universe, and then go through duplicate installations of the library to find the one we are looking for, we need to learn some Nix commands.

First, we need to enter a Nix REPL environment to resolve the package directly. REPL stands for Read-Eval-Print Loop, which is a powerful environment for testing various Nix expressions. We can access it with the primary `nix` command.

```
> nix repl
nix-repl> pkgs = import <nixpkgs> {}
nix-repl> pkgs.glm
«derivation /nix/store/25rdysybbl5aangkgkdznc57xfihq2zk-glm-1.0.1.drv»
```

This article assumes you already have basic familiarity with the Nix language, so a crash course for it will not be interleaved. But as a side note, attributes in Nix are evaluated lazily, so we do not worry about the import taking a long time. This is due to the fact that lazy evaluation guarantees expressions are evaluated only when they are needed, not when they are defined.

The last command yields a path because the interpreter treats it as a special kind of attribute set that was introduced as a derivation. Indeed, we can confirm that this attribute is of type derivation by running another command in the environment.

```
nix-repl> lib = pkgs.lib
nix-repl> lib.attrsets.isDerivation pkgs.glm
true
```

(Pro Tip: Use [noogle.dev](https://noogle.dev/) for looking through `lib` and [mynixos.com](https://mynixos.com/) for looking through `pkgs`.)

From the penultimate set of commands, we infer that the derivation is located at `/nix/store/25rdysybbl5aangkgkdznc57xfihq2zk-glm-1.0.1.drv`. (Derivations always use the `.drv` file extension.)

Every derivation (`.drv`) has a set of outputs. When a derivation is realised (i.e. built), these become what we will find out to be *store paths*.

The next step is finding the actual store path where the library file (`.a` or `.so`) resides in. We can use the `nix-store` command to achieve this.

```
> nix-store --query --outputs /nix/store/25rdysybbl5aangkgkdznc57xfihq2zk-glm-1.0.1.drv
/nix/store/gkahdgly8x8z8b6cvgab4gij0niajx7x-glm-1.0.1-doc
/nix/store/nlrq8s273x3kbm2w4g90pymx1ab9ww3p-glm-1.0.1
```

The latter is the one we are looking for. This shows that store paths are blobs in the Nix store where different versions of the same package may exist. It is now trivial to list the `lib` directory, which reveals that the library is there and is statically-linked.

```
> ls /nix/store/nlrq8s273x3kbm2w4g90pymx1ab9ww3p-glm-1.0.1/lib
libglm.a
pkgconfig
```

For programmers, it should be unsurprising that it is not in some sort of path because it need not be resolved automatically. Later, we will see that this is not the case for the other type of libraries.

It is also possible to inspect the derivation itself in a human-readable JSON form with the `nix` command, which lists the mysterious outputs that were mentioned before:

```
> nix derivation show /nix/store/25rdysybbl5aangkgkdznc57xfihq2zk-glm-1.0.1.drv
...lots of json output
```

I will provide a snippet for the part of the JSON that contains the outputs:
```
"outputs": {
  "doc": {
    "path": "/nix/store/gkahdgly8x8z8b6cvgab4gij0niajx7x-glm-1.0.1-doc"
  },
  "out": {
    "path": "/nix/store/nlrq8s273x3kbm2w4g90pymx1ab9ww3p-glm-1.0.1"
  }
}
```

It is not hard to deduce from this that outputs have a one-to-one correspondence with store paths. So that is what they create when you *realise* (i.e. build) a derivation with:

```
> nix-store --realize /nix/store/25rdysybbl5aangkgkdznc57xfihq2zk-glm-1.0.1.drv
```

Note that the `.drv` file that has produced the store path we are looking for is called the *deriver*. The inverse operation—finding a derivation from a store path—simply involves asking for the deriver.

```
> nix-store --query --deriver /nix/store/nlrq8s273x3kbm2w4g90pymx1ab9ww3p-glm-1.0.1/
/nix/store/25rdysybbl5aangkgkdznc57xfihq2zk-glm-1.0.1.drv
```

Now suppose you had a store path with an executable, say `git`. We can leverage the fact that it is in the path to track it down more easily and figure out more stuff about our system. First, we find where its reference is in the path.

```
> which git
/home/user/.nix-profile/bin/git
```

This is part of the running user profile. This is by convention a symlink, so using `ls` we can find its store path:

```
> ls -l /home/user/.nix-profile/bin/git
lrwxrwxrwx 20 root root 62 Jan  1  1970 /home/user/.nix-profile/bin/git -> /nix/store/v2rxk9xkcxsas64wl7ds31al15cm2wqd-git-2.50.1/bin/git
```

Equivalently, NixOS has a system profile, which resides in `/run/current-system`; it is the same as `/nix/var/nix/profiles/system`, whose content follows this structure:

```
> tree /run/current-system
/run/current-system
├── activate
├── append-initrd-secrets -> /nix/store/854r1y7ds8gpb590ykp80pp8abxvh8rz-append-initrd-secrets/bin/append-initrd-secrets
├── bin
│   └── switch-to-configuration
├── boot.json
├── dry-activate
├── etc -> /nix/store/5421s9d4gxacbb1qz4bcpbzpri3fs9rf-etc/etc
├── extra-dependencies
├── firmware -> /nix/store/f4qr5qzy42058jdhb3b72hv2jibx66jm-firmware/lib/firmware
├── init
├── init-interface-version
├── initrd -> /nix/store/kbsga64nqsyqmq8yscppi14wzwvpmkh8-initrd-linux-hardened-6.12.43/initrd
├── kernel -> /nix/store/xdj4kqzlq81vpcivbjfjqs0gjkymd5lp-linux-hardened-6.12.43/bzImage
├── kernel-modules -> /nix/store/h1675il6j7xik802qcv5lhz2mijz934i-linux-hardened-6.12.43-modules
├── kernel-params
├── nixos-version
├── specialisation
│   └── no-apparmor -> /nix/store/avbh20p5w5q9014qdargli4dia9j2gg7-nixos-system-nixtra-personal-25.05.20250929.5ed4e25
├── sw -> /nix/store/fbdm2v6r78w3n0a7f78pbnjdwpdwi12x-system-path
├── system
└── systemd -> /nix/store/d84f8nm2na5cr53m4jk0qk2mj7lgr9fx-systemd-257.9
```

The only difference one needs to understand at this stage of learning is that the packages you install with Home Manager will be in the user profile, and the ones you do not are in the system profile.

Furthermore, `/run/current-system/sw` (where `sw` is a shorthand for "software") is where all of our executables are symlinked to. And unsuprisingly, these symlinks point to the store paths we discussed!

```
> ls -l /run/current-system/sw
lrwxrwxrwx 11 root root 55 Jan  1  1970 /run/current-system/sw -> /nix/store/fbdm2v6r78w3n0a7f78pbnjdwpdwi12x-system-path
> ls /nix/store/fbdm2v6r78w3n0a7f78pbnjdwpdwi12x-system-path
bin
etc
lib
sbin
share
```

An important interjection here is that, since `glm` is a static library, it is not located in the `lib` subdirectory; only shared library files (`.so`) are in it. You can imagine an equivalent `$PATH` existing for shared libraries, which is this path.

Returning to our ongoing investigation, since Git is installed system-wide, you can probably guess that it is in the bin directory, which in turn is symlinked to the store path we previously discovered. 

```
> ls -l /nix/store/fbdm2v6r78w3n0a7f78pbnjdwpdwi12x-system-path/bin/git
lrwxrwxrwx 62 root root 65 Jan  1  1970 /nix/store/fbdm2v6r78w3n0a7f78pbnjdwpdwi12x-system-path/bin/git -> /nix/store/gz9a9vvx15cwznzw2h1gr4k7778bbgqk-firejail-wrap/bin/git
```

And this concludes our witchhunt! We have seen how all of these things are interconnected in the ecosystem, and you have learned basic traversal of this complex monolith called the Nix store. I leave the traversal of the user profile located in `~/.nix-profile` as an exercise to the reader.

To summarize everything that I demonstrated, below is a cheatsheet of the commands and material introduced above.

- `nix-store --query --outputs <derivation>`: fetch the store paths associated with a derivation
- `nix-store --query --deriver <store-path>`: fetch the derivation that a store path originates from
- `nix derivation show <derivation>`: inspect a derivation in human-readable JSON form
- `/run/current-system`: the NixOS system profile; same as `/nix/var/nix/profiles/system`
- `~/.nix-profile`: the NixOS user profile

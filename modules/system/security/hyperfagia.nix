{
  lib,
  inputs,
  settings,
  profileSettings,
  config,
  ...
}:

let
  frozenPkgs = import inputs.nixpkgs-hyperfagia {
    system = profileSettings.arch;
    config.allowUnfree = true;
  };

  resolvedSpl = config.nixtra.security.hyperfagia.spl frozenPkgs;

  hyperfagiaOverlay = (
    final: prev:
    builtins.listToAttrs (
      map (pkg: {
        name = lib.getName pkg;
        value = frozenPkgs.${pkg};
      }) resolvedSpl
    )
  );
in
{
  disabledModules = settings.security.hyperfagia.ssl;
  imports = map (
    service: "${inputs.nixpkgs-frozen}/nixos/modules/${service}"
  ) settings.security.hyperfagia.ssl;
  nixpkgs.overlays = [ hyperfagiaOverlay ];
}

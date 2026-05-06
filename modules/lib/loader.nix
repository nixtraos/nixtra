# WARNING: The functions here are experimental
# and NOT ready to be used; the conditional
# import function works for NixOS module,
# but does not work for Home Manager modules.

{
  config,
  pkgs,
  lib,
  ...
}:

let
  evalModule =
    allArgs: raw:
    if builtins.isFunction raw then
      raw allArgs
    else if builtins.isList raw then
      lib.mkMerge (
        map (
          elem:
          let
            m = if builtins.isFunction elem then elem allArgs else elem;
          in
          if builtins.isAttrs m then m else { }
        ) raw
      )
    else if builtins.isAttrs raw then
      raw
    else
      { };
in
rec {
  # The Nixtra module system provides this special
  # utility for conditional importing.
  #
  # With the NixOS module system, it is not trivially
  # possible to import conditionally with a `config` predicate
  # because, as explained in the docs, that results in a
  # circular dependency between modules. Normally, to fix this,
  # you need to prepend lib.mkIf to every single module file
  # that requires a certain `config` predicate, just like
  # in nixpkgs. But in Nixtra, users have their own flavors
  # for desktop rices and other centralized forms of
  # configuration; it is not ergonomic to have to do this
  # for every file.
  #
  # To use this special utility, simply add it to your imports
  # like so:
  #
  # ```nix
  # imports = [
  #   (nixtraLib.loader.conditionalImport config.some-condition ./some-import.nix)
  # ]
  # ```
  #
  # A Nix module consists of `imports`, `config`, and `options`.
  # The recursive descent ONLY works with the following root attributes:
  # `config`, `imports`
  #
  # Also, other root attributes implicitly become part of `config`,
  # but if you import a module with this you have to put them under
  # the `config` namespace expicitly.
  #
  # TODO: Make this system more flexible.
  #conditionalImport = condition: path:
  #  let raw = import path;
  #  in (args:
  #    let
  #      standardArgs = { inherit config lib pkgs; };
  #      requiredArgs = args;
  #      allArgs = requiredArgs // standardArgs;
  #    in {
  #      options = if (builtins.isAttrs (evalModule allArgs raw)
  #        && builtins.hasAttr "options" (evalModule allArgs raw)) then
  #        (evalModule allArgs raw).options
  #      else
  #        { };

  #      config = lib.mkIf condition
  #        (if (builtins.isAttrs (evalModule allArgs raw)
  #          && builtins.hasAttr "config" (evalModule allArgs raw)) then
  #          (evalModule allArgs raw).config
  #        else
  #          { } // (if (builtins.isAttrs (evalModule allArgs raw)) then
  #            (builtins.removeAttrs (evalModule allArgs raw) [
  #              "imports"
  #              "options"
  #            ]) # Get all the implicit config declarations
  #          else
  #            { }) // (if (builtins.isAttrs (evalModule allArgs raw)
  #              && builtins.hasAttr "imports" (evalModule allArgs raw)
  #              && (evalModule allArgs raw).imports != [ ]) then
  #              (lib.mkMerge (map (innerModule:
  #                ((conditionalImport condition innerModule) allArgs).config)
  #                (evalModule allArgs raw).imports))
  #            else
  #              { }));
  #    });

  ## Same as above, but with multiple resolved paths.
  #conditionalImports = condition: paths:
  #  lib.mkMerge (map (path: conditionalImport condition path) paths);
}

{ pkgs, lib, ... }:
{
  wrapFirejail =
    {
      executable,
      desktop ? null,
      applications ? null,
      profile ? null,
      sandboxLabel ? null,
      isolateData ? true,
      autoPrivateBin ? true,
      extraArgs ? [ ],
    }:
    let
      executableName = builtins.baseNameOf executable;
      sandboxName = if (builtins.isString sandboxLabel) then sandboxLabel else executableName;
      isolationDir = lib.optionalString isolateData ''
        mkdir ''${HOME}/Sandbox
        mkdir ''${HOME}/Sandbox/${sandboxName}
        whitelist ''${HOME}/Sandbox/${sandboxName}
      '';
      privateBin = lib.optionalString autoPrivateBin ''
        private-bin ${executable}
      '';
      preludeBody = lib.concatStringsSep "\n" [
        isolationDir
        privateBin
      ];
      prelude = lib.optionalString (preludeBody != "") ''
        # GENERATED AND MANAGED AUTOMATICALLY BY wrapFirejail
        ##########################

        ${preludeBody}
        ##########################

      '';

      profileFile =
        if profile == null then
          null
        else if (builtins.isPath profile) then
          (pkgs.writeText "${builtins.baseNameOf profile}.profile" (prelude + builtins.readFile profile))
        else if (builtins.isString profile) then
          let
            profilePath = (
              builtins.toString ../system/security/firejail/profiles + ("/" + profile) + ".profile"
            );
          in
          (pkgs.writeText "${builtins.baseNameOf executable}.profile" (
            (prelude + builtins.readFile profilePath)
          ))
        else
          builtins.trace (
            "wrapFirejail: invalid `profile` — expected a string, path, or null; got " + builtins.typeOf profile
          );

    in
    pkgs.runCommand "firejail-wrap"
      {
        preferLocalBuild = true;
        allowSubstitutes = false;
        meta.priority = -1; # Take precedence over non-firejailed versions.
      }
      (
        let
          firejailArgs = lib.concatStringsSep " " (
            extraArgs ++ (lib.optional (profileFile != null) "--profile=${profileFile}")
          );
        in
        ''
          command_path="$out/bin/$(basename ${executable})"
          mkdir -p $out/bin
          mkdir -p $out/share/applications
          cat <<'_EOF' >"$command_path"
          #! ${pkgs.runtimeShell} -e
          exec /run/wrappers/bin/firejail ${firejailArgs} -- ${toString executable} "$@"
          _EOF
          chmod 0755 "$command_path"
        ''
        + lib.optionalString (applications != null) ''
          find ${applications} -type f | while IFS= read -r f; do
            base=$(basename "$f")
            substitute "$f" $out/share/applications/$base \
              --replace ${executable} "$command_path"
          done
        ''
        + lib.optionalString (desktop != null) ''
          substitute ${desktop} $out/share/applications/$(basename ${desktop}) \
            --replace ${executable} "$command_path"
        ''
      );

  torify =
    program:
    pkgs.writeShellScriptBin (builtins.baseNameOf program) ''
      exec ${pkgs.torsocks}/bin/torsocks ${program} "$@"
    '';
}

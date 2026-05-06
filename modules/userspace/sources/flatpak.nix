{
  config,
  lib,
  pkgs,
  ...
}:

if config.nixtra.flatpak.enable then
  {
    home.packages = with pkgs; [
      flatpak
      bubblewrap # Dependency of flatpak
    ];

    home.activation = {
      installFlathub = lib.hm.dag.entryAfter [ "writeBoundary" ] (
        lib.concatStringsSep "\n" (
          map (source: ''
            ${pkgs.flatpak}/bin/flatpak remote-add --user --if-not-exists ${source.name} ${source.source}
          '') config.nixtra.flatpak.sources
        )
      );

      installFlatpakPackages = lib.hm.dag.entryAfter [ "writeBoundary" ] (
        lib.concatStringsSep "\n" (
          map (
            app:
            let
              installType = if app.user then "user" else "system";

              installCommand =
                if builtins.hasAttr "source" app then
                  "${pkgs.flatpak}/bin/flatpak install --${installType} --assumeyes --noninteractive ${app.source} ${app.app}"
                else
                  ''
                    export PATH=/run/wrappers/bin:$PATH
                    tmpdir=$(mktemp -d)
                    ${pkgs.curl}/bin/curl -Lo "$tmpdir/app.flatpak" ${app.url}
                    ${pkgs.doas}/bin/doas ${pkgs.flatpak}/bin/flatpak install --${installType} --assumeyes --noninteractive "$tmpdir/app.flatpak"
                    rm -rf "$tmpdir"
                  '';
            in
            ''
              if ! ${pkgs.flatpak}/bin/flatpak list --app --${installType} | grep -q ${app.app}; then
                ${installCommand}
              fi
            ''
          ) config.nixtra.flatpak.apps
        )
      );
    };
  }
else
  { }

{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf (config.nixtra.user.desktop == "flagship-hyprland") {
    systemd.user.services."switch-wallpaper" = {
      Service = {
        ExecStart =
          let
            wallpaperPaths = (
              lib.concatStringsSep " " (
                map (
                  extension: "${config.nixtra.desktop.wallpaper.directory}/*.${extension}"
                ) config.nixtra.desktop.wallpaper.extensions
              )
            );
            script = pkgs.writeShellScriptBin "switch-wallpaper" ''
              export PATH=${pkgs.swww}/bin:${pkgs.procps}/bin:$PATH

              WALLPAPER_DIR="${config.nixtra.desktop.wallpaper.directory}"

              if [ ! -d "$WALLPAPER_DIR" ]; then
                echo "Error: Wallpaper directory $WALLPAPER_DIR does not exist."
                exit 1
              fi

              files=(${wallpaperPaths})

              if [ ''${#files[@]} -eq 0 ]; then
                echo "Error: No files found in $WALLPAPER_DIR"
                exit 1
              fi

              while true; do
                random_wallpaper="''${files[RANDOM % ''${#files[@]}]}"

                pkill -x swww || true

                echo "Setting wallpaper: $random_wallpaper"
                swww img -t random "$random_wallpaper"

                echo "Wallpaper set successfully!"

                sleep ${builtins.toString config.nixtra.desktop.wallpaper.switchInterval}
              done
            '';
          in
          "${script}/bin/switch-wallpaper";

        Type = "simple";
        WorkingDirectory = "/home"; # Required to access home directory files
        ProtectHome = false;
        Restart = "always";
        RestartSec = 0;
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}

{
  config,
  pkgs,
  createCommand,
  ...
}:

createCommand {
  name = "screenshot";
  buildInputs = with pkgs; [
    grim
    slurp
  ];

  command = # bash
    ''
      arg="''${1:-}"

      if [ "$arg" = "region" ]; then
        ${pkgs.slurp}/bin/slurp | ${pkgs.grim}/bin/grim -g - screenshot.png
      else
        ${pkgs.grim}/bin/grim screenshot.png
      fi
    '';
}

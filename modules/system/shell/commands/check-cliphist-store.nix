{
  config,
  pkgs,
  createCommand,
  ...
}:

let
  excludedPattern = pkgs.lib.concatStringsSep "|" config.nixtra.security.excludedClipboardPrograms;
in
createCommand {
  name = "check-cliphist-store";
  buildInputs = with pkgs; [
    wl-clipboard
    cliphist
    gnugrep
  ];

  command = # bash
    ''
      if ! ${pkgs.wl-clipboard}/bin/wl-paste --list-types | \
           ${pkgs.gnugrep}/bin/grep -qE "${excludedPattern}"; then
        ${pkgs.cliphist}/bin/cliphist store
      fi
    '';
}

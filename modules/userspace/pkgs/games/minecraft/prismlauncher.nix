{
  config,
  lib,
  pkgs,
  nixtraLib,
  ...
}:

{
  home.packages = [
    (nixtraLib.sandbox.wrapFirejail {
      # executable = "${
      #     pkgs.writeShellScriptBin "prismlauncher" ''
      #       export LD_LIBRARY_PATH=${pkgs.kdePackages.full}/lib:$LD_LIBRARY_PATH
      #       exec ${prismlauncher-unwrapped}/bin/prismlauncher
      #     ''
      #   }/bin/prismlauncher";
      executable = "${pkgs.prismlauncher}/bin/prismlauncher";
      profile = "prismlauncher";
    })
    pkgs.prismlauncher
  ];
}

# export PATH=${
#   lib.concatStringsSep ":" [
#     (lib.concatStringsSep ":" (map (pkg: "${pkg}/bin") javaPkgs))
#     "$PATH"
#   ]
# }

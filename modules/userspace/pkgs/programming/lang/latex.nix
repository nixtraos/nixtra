{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ (texliveFull.withPackages (ps: [ ps.bytefield ])) ];
}

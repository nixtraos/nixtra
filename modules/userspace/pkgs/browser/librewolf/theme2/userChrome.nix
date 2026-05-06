{ config, lib }:

lib.concatStringsSep "\n" (
  map (file: builtins.readFile file) [
    ./chrome/hide-tabs.css
    ./chrome/tst.css
    ./chrome/navbar/navbar.css
  ]
)

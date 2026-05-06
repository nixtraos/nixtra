{ config, pkgs, ... }:

{
  performance = {
    useHugePages = true;
  };

  system = {
    kernel = "gaming";
  };
}

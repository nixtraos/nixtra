{ pkgs, ... }:

{
  services.nginx = {
    enable = true;
    package = pkgs.nginxMainline;
    recommendedGzipSettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
  };
}

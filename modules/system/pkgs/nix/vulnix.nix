{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (python3.withPackages (
      ps: with ps; [
        vulnix
        zope-interface
      ]
    ))

    vulnix
  ];
}

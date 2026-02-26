{ pkgs ? import <nixpkgs> {} }:

pkgs.qt6Packages.callPackage ./derivation.nix {}

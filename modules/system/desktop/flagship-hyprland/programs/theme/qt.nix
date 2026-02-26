# https://discourse.nixos.org/t/guide-to-installing-qt-theme/35523/2

{ config, lib, pkgs, ... }:

{
  config = lib.mkIf (config.nixtra.user.desktop == "flagship-hyprland") {
    environment.systemPackages = with pkgs;
      with qt6; [
        libsForQt5.qtstyleplugin-kvantum
        libsForQt5.qt5ct
        qmake
        qt3d
        qt5compat
        qtbase
        qtcharts
        qtconnectivity
        qtdatavis3d
        qtdeclarative
        qtdoc
        qtgraphs
        qtgrpc
        qthttpserver
        qtimageformats
        qtlanguageserver
        qtlocation
        qtlottie
        qtmqtt
        qtmultimedia
        qtnetworkauth
        qtpositioning
        qtquick3d
        qtquick3dphysics
        qtquickeffectmaker
        qtquicktimeline
        qtremoteobjects
        qtscxml
        qtsensors
        qtserialbus
        qtserialport
        qtshadertools
        qtspeech
        qtsvg
        qttools
        qttranslations
        qtvirtualkeyboard
        qtwayland
        qtwebchannel
        qtwebengine
        qtwebsockets
        qtwebview
      ];

    #nixpkgs.config.qt5 = {
    #  enable = true;
    #  platformTheme.name = "qt5ct";
    #  style = {
    #    package = pkgs.utterly-nord-plasma;
    #    name = "Utterly Nord Plasma";
    #  };
    #};

    qt = {
      enable = true;
      style = "kvantum";
      platformTheme = "qt5ct";
    };

    environment.variables = {
      QT_QPA_PLATFORMTHEME = "qt5ct";
      QT_STYLE_OVERRIDE = "kvantum";
    };
  };
}

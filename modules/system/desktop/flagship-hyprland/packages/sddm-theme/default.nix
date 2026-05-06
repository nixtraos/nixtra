{
  lib,
  qtbase,
  qtsvg,
  qtgraphicaleffects,
  qtquickcontrols2,
  wrapQtAppsHook,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation rec {
  pname = "tokyo-night-sddm";
  version = "1..0";
  dontBuild = true;
  src = ./.;
  nativeBuildInputs = [ wrapQtAppsHook ];

  propagatedUserEnvPkgs = [
    qtbase
    qtsvg
    qtgraphicaleffects
    qtquickcontrols2
  ];

  installPhase = ''
    mkdir -p $out/share/sddm/themes
    cp -aR $src $out/share/sddm/themes/tokyo-night-sddm
  '';
}

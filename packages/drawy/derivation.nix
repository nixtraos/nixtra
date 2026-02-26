{ stdenv, lib, fetchFromGitHub,
  cmake, wrapQtAppsHook,
  qtbase
}:

stdenv.mkDerivation rec {
  pname = "drawy";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Prayag2";
    repo = pname;
    rev = "1.0.0-alpha";
    sha256 = "sha256-5hv6iBTXTXwsmtjzRA+dAIzx/5jtWcOEfORMK0l1DSk=";
  };

  nativeBuildInputs = [
    cmake
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
  ];
}

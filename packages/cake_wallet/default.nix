# requires flutter 3.22.1/3.22.2
{
  lib,
  stdenv,
  fetchurl,
  fetchgit,
  fetchFromGitHub,
  which, # CLI utils
  cmake,
  ninja,
  autoconf,
  automake,
  ccache,
  xcbuild, # Build
  gcc,
  clang,
  rustc,
  cargo-ndk,
  go,
  llvm_21,
  dart,
  flutter, # Language
  git,
  curl, # Network
  glib,
  pkg-config,
  util-linux,
  libselinux,
  mount,
  udisks2,
  pcre,
  pcre2,
  libsysprof-capture,
  libtool,
  gperf,
  gtk3,
  expat,
  unzip,
  libsepol,
  gobject-introspection,
  libthai,
  libdatrie,
  xorg,
  lerc,
  libxkbcommon,
  libepoxy, # Library
  androidenv,
  sdkmanager, # Android SDK
  cacert,
  dbus,
  ...
}:
let
  flutterVersion = "3.22.1";
  flutter3221 = flutter.overrideAttrs (old: rec {
    version = flutterVersion;
    src = fetchurl {
      url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${flutterVersion}-stable.tar.xz";
      sha256 = "sha256-+4zjD9Idj0PNJUCvbZ+UUsv8gKhXBvJssHI4b8Ufv84="; # use `nix-prefetch-url --unpack` to get this
    };
    dartHash = lib.fakeSha256; # fetch from Dart release notes
    engineVersion = "55eae6864b296dd9f43b2cc7577ec256e5c32a8d";
  });
  aenv = androidenv.override { licenseAccepted = true; };
  comp = aenv.composeAndroidPackages {
    platformVersions = [ "35" ];
    abiVersions = [ "arm64-v8a" ];
    extraLicenses = [ ]; # if you need extra ones
  };
  androidsdk = comp.androidsdk;
in
stdenv.mkDerivation rec {
  pname = "cake_wallet";
  version = "5.1.2";

  src = fetchFromGitHub {
    owner = "cake-tech";
    repo = "cake_wallet";
    rev = "v${version}";
    sha256 = "sha256-4hvdDtUR8OOQtkMcGxTiIiFFD4VpfN89aJk9fzpogEw=";
  };

  #monero_c = fetchFromGitHub {
  #  owner = "mrcyjanek";
  #  repo = "monero_c";
  #  rev = "b576312e4d466569cd03482b61c597b39a9f4dc3";
  #  sha256 = "sha256-p7zATtl0WTznsvw87d3yP5K/jzMyUJJ2nUG5nWC5mQ8=";
  #  leaveDotGit = true;
  #  fetchSubmodules = true;
  #  forceFetchGit = true;
  #};

  monero_c = fetchgit {
    url = "https://github.com/mrcyjanek/monero_c";
    rev = "b576312e4d466569cd03482b61c597b39a9f4dc3";
    sha256 = "sha256-8Ox2eBNkVv5UdmCcr1em18iSAW9gWT5E7C5gzrY29B4=";
    #sha256 = "sha256-+JX2CCwxF9LvVW0TXjJV1zcmxBW3ejsos9aNij9Fczo=";
    #sha256 = "sha256-p7zATtl0WTznsvw87d3yP5K/jzMyUJJ2nUG5nWC5mQ8=";
    leaveDotGit = true;
    fetchSubmodules = true;
    deepClone = true;
  };

  #cmakeFlags = [
  #  (lib.cmakeFeature "CMAKE_C_FLAGS_RELEASE" "-DNDEBUG")
  #  (lib.cmakeFeature "CMAKE_CXX_FLAGS_RELEASE" "-DNDEBUG")
  #  (lib.cmakeOptionType "-DCMAKE_CXX_COMPILER" "${clang}/bin/clang++")
  #];

  cxx = clang;
  nativeBuildInputs = [
    cmake
    ninja
    autoconf
    automake
    ccache
    gcc
    rustc
    cargo-ndk
    go
    flutter
    llvm_21
    dart
    git
    curl
    glib
    pkg-config
    util-linux
    libselinux
    mount
    udisks2
    pcre
    pcre2
    libsysprof-capture
    libtool
    gperf
    gtk3
    expat
    unzip
    libsepol
    gobject-introspection
    libthai
    libdatrie
    xorg.libXdmcp
    xorg.libXtst
    lerc
    libxkbcommon
    libepoxy
    androidsdk
    sdkmanager
    cacert
    xcbuild
  ];
  buildInputs = [
    gtk3
    pkg-config
    dbus
  ];

  inherit dbus;

  #postUnpack = ''
  #  cp -rT --reflink=auto "${monero_c}" monero_c/
  #'';

  configurePhase = ''
    # add bogus code here to override standard configurePhase instructions
    cd linux
    cd ..
  '';

  preBuild = ''
    cp -rT "${monero_c}" $PWD/scripts/monero_c
    chmod -R u+w $PWD/scripts/monero_c
    patchShebangs --build .
    # circumvent sandbox violation
    substituteInPlace scripts/prepare_moneroc.sh \
      --replace-fail "git clone https://github.com/mrcyjanek/monero_c --branch master monero_c" "true"
    # remove duplicate patch application
    substituteInPlace scripts/prepare_moneroc.sh \
      --replace-fail "./apply_patches.sh \$coin" "true"
  '';

  buildPhase = ''
    runHook preBuild

    export PKG_CONFIG_PATH="${pkg-config}/lib"
    export FLUTTER_ROOT=${flutter}
    export PATH=$PATH:$FLUTTER_ROOT

    mkdir tmp-home
    export FLUTTER_HOME=$(pwd)/tmp-home
    export HOME=$(pwd)/tmp-home

    #flutter --disable-analytics
    #flutter config --no-enable-ios --no-enable-android
    #flutter precache

    # fix all shebangs (replaced /bin/bash to /usr/bin/env bash)
    #find . -type f -name '*.sh' -exec sed -i '1s|^#! */bin/bash|#!/usr/bin/env bash|' {} +
    #find . -type f -name '*.sh' -exec sed -i '1s|^#! */bin/bash||' {} +

    cd ./scripts/linux/

    # something in the script subsequently does a git action that requires identification, so use official credentials
    git config --global user.email "czarek@cakewallet.com"
    git config --global user.name "CakeWallet CI"

    # configure
    ./cakewallet.sh

    # build native monero comp via cmake
    ./build_all.sh
    ./setup.sh

    cd ../..

    # build flutter side
    echo "building with flutter..."
    #flutter pub get
    dart run tool/generate_new_secrets.dart
    ./model_generator.sh
    dart run ../tool/generate_localization.dart

    # package
    flutter build linux --release

    runHook postBuild
  '';

  preInstall = "";

  installPhase = ''
    runHook preInstall

    install -Dm755 build/cake_wallet $out/bin/cake_wallet

    mkdir -p $out/share/applications
    substitute ../dist/linux/info.cemu.Cemu.desktop $out/share/applications/info.cemu.Cemu.desktop \
      --replace-fail "Exec=Cemu" "Exec=$out/bin/Cemu"

    install -Dm644 assets/images/cakewallet_icon_180.png $out/share/icons/hicolor/128x128/apps/info.cemu.Cemu.png

    runHook postInstall
  '';

  meta = with lib; {
    description = "An open source, noncustodial and multi-currency wallet.";
    homepage = "https://cakewallet.com/";
    license = licenses.mit;
    maintainers = [ quarterstar ];
    platforms = platforms.linux;
  };
}

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gcc
    clang-tools
    llvmPackages.clang-tools
    #clang
    meson
    ninja
    cmake
    #conan
    pkg-config
  ];

  home.sessionVariables = {
    #CPLUS_INCLUDE_PATH =
    #  "${pkgs.gcc.cc}/include/c++/${pkgs.gcc.version}:${pkgs.gcc.cc}/include/c++/${pkgs.gcc.version}/x86_64-linux-gnu";
  };
}

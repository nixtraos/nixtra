let
  pkgs = import <nixpkgs> { };
in
pkgs.mkShell {
  packages = [
    (pkgs.python3.withPackages (python-pkgs: [
      python-pkgs.openai
      python-pkgs.kitty
      python-pkgs.kittens
      python-pkgs.python-dotenv
    ]))
  ];
}

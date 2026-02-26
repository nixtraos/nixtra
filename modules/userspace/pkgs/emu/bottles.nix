{ pkgs, nixtraLib, ... }:

let bottles = pkgs.bottles.override { removeWarningPopup = true; };
in {
  home.packages = [
    (nixtraLib.sandbox.wrapFirejail {
      executable = "${bottles}/bin/bottles";
      profile = "bottles";
    })
    (nixtraLib.sandbox.wrapFirejail {
      executable = "${bottles}/bin/bottles-cli";
      profile = "bottles-cli";
    })
    bottles
  ];
}

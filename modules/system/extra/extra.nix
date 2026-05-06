{
  config,
  pkgs,
  inputs,
  ...
}:

{
  nixpkgs.config.allowUnfree = true;

  environment.etc."libinput/local-overrides.quirks".text = ''
    [Glorious Model O]
    MatchName=Glorious Model O
    ModelBouncingKeys=1

    [Glorious Model O Keyboard]
    MatchName=Glorious Model O Keyboard
    ModelBouncingKeys=1
  '';
}

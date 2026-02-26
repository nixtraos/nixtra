{ profileSettings, inputs, ... }:

{
  home.packages =
    [ inputs.wayscriber.packages.${profileSettings.arch}.default ];
}

{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf (config.nixtra.user.desktop == "flagship-hyprland") {
    #xdg.dataFile."rofi/config.rasi".text = ''
    #  @theme "~/.local/share/rofi/themes/nixtra.rasi"
    #'';

    xdg.configFile."rofi/config.rasi".text = ''
      @theme "~/.config/rofi/themes/nixtra.rasi"
    '';

    xdg.configFile."rofi/themes/nixtra.rasi".text = ''
      * {
          font:   "Roboto 12";

          bg1:    #1f2759;
          bg2:    #4C566A80;
          bg3:    #1f2759;
          fg0:    #ae5ffc;
          fg2:    #bc87f2;
          fg3:    rgba(255, 255, 255, 0.2);
          fg4:    #7645a8;

          background-color:   transparent;
          text-color:         @fg0;

          margin:     0px;
          padding:    0px;
          spacing:    0px;
      }

      window {
          width:          600;
          border-radius:  12px;

          location:       north;
          y-offset:       calc(50% - 176px);

          background-color:   rgba(31, 39, 89, 0.7);
      }

      mainbox {
          padding:    12px;
      }

      inputbar {
          /* background-color:   @bg1; */

          border:         2px;
          border-radius:  16px;

          padding:    8px 16px;
          spacing:    8px;
          children:   [ prompt, entry ];
      }

      prompt {
          text-color: @fg2;
      }

      entry {
          placeholder:        "Search";
          placeholder-color:  @fg3;
      }

      message {
          margin:             12px 0 0;
          border-radius:      16px;
          border-color:       @bg2;
          background-color:   @bg2;
      }

      textbox {
          padding:    8px 24px;
      }

      listview {
          background-color:   transparent;

          margin:     12px 0 0;
          lines:      8;
          columns:    1;

          fixed-height: false;
      }

      element {
          padding:        8px 16px;
          spacing:        8px;
          border-radius:  16px;
      }

      element normal active {
          /* text-color: @bg3; */
      }

      element alternate active {
          /* text-color: @bg3; */
      }

      element selected normal, element selected active {
          background-color:   @bg3;
      }

      element-icon {
          size:           1em;
          vertical-align: 0.5;
      }

      element-text {
          text-color: inherit;
      }

      element selected {
          text-color: @fg4;
      }
    '';
  };
}

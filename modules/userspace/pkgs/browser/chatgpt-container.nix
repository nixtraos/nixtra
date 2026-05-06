{ config, pkgs, ... }:

{
  programs.firefox.enable = true;

  programs.firefox.policies.Preferences = {
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    "browser.shell.checkDefaultBrowser" = false;
    "dom.webnotifications.enabled" = false;
    "dom.push.enabled" = false;
    "dom.popup_allowed_events" = "";
    "dom.disable_open_during_load" = true;
    "permissions.default.desktop-notification" = 2;
    "permissions.default.geo" = 2;
    "permissions.default.camera" = 2;
    "permissions.default.microphone" = 2;
    "privacy.popups.showBrowserMessage" = false;
    DisableAppUpdate = true;
    DisableTelemetry = true;
    Notifications = {
      Blocked = [ "*" ];
    };
    PopupBlocking = {
      Enabled = true;
    };
    Permissions = {
      Camera = "block";
      Microphone = "block";
      Geolocation = "block";
      Notifications = "block";
    };
  };

  programs.firefox.profiles."chatgpt" = {
    userChrome = ''
      #TabsToolbar {
        visibility: collapse !important;
      }

      #nav-bar {
        visibility: collapse !important;
      }

      #PersonalToolbar {
        visibility: collapse !important;
      }

      #sidebar-box,
      #sidebar-splitter {
        visibility: collapse !important;
      }
    '';

    userContent = ''
      @-moz-document domain(chat.openai.com) {
              div[class*="Sidebar"] {
                      display: none !important;
              }
      }
    '';
  };

  home.packages = [
    (pkgs.writeShellScriptBin "firefox-chatgpt" ''
      exec ${pkgs.firefox}/bin/firefox \
        -kiosk \
        --no-remote \
        -P chatgpt \
        --new-window chat.openai.com
    '')
  ];

  xdg.desktopEntries.firefox-chatgpt = {
    name = "Firefox (ChatGPT Container)";
    genericName = "Web Browser";
    exec = "firefox-chatgpt";
    icon = "firefox";
    terminal = false;
    categories = [
      "Network"
      "WebBrowser"
    ];
  };
}

{ nixtraLib, config, pkgs, ... }:

let
  tor-browser-clearnet = pkgs.tor-browser.override {
    extraPrefs = ''
      lockPref("extensions.torlauncher.prompt_at_startup", false)
      lockPref("extensions.torlauncher.start_tor", false)
      lockPref("extensions.torbutton.use_nontor_proxy", true)
      lockPref("network.dns.disabled", false)
      lockPref("network.proxy.socks", " ")
      lockPref("network.proxy.type", 0)
    '';
  };

  tor-browser-proxy = pkgs.tor-browser.override {
    # network.trr.mode set to 0 to be able to access .onion hidden services
    extraPrefs = ''
      lockPref("extensions.torlauncher.prompt_at_startup", false)
      lockPref("extensions.torbutton.use_nontor_proxy", true)
      lockPref("network.proxy.socks", "127.0.0.1")
      lockPref("network.proxy.socks_port", 1080)
      lockPref("extensions.torlauncher.start_tor", false)
      lockPref("browser.startup.homepage", "file://${
        ./web/pages/tor-browser-proxy-warning.html
      }")
    '';
  };

  #tor-browser = pkgs.tor-browser.override { extraPrefs = ""; };

  # Create wrapper scripts
  tor-browser-clearnet-wrapper =
    pkgs.writeShellScriptBin "tor-browser-clearnet" ''
      #export TOR_BROWSER_PROFILE_DIR="$HOME/.tor-browser-clearnet"
      #exec ${tor-browser-clearnet}/bin/tor-browser --profile "$TOR_BROWSER_PROFILE_DIR" "$@"
      exec ${tor-browser-clearnet}/bin/tor-browser "$@"
    '';

  tor-browser-proxy-wrapper = pkgs.writeShellScriptBin "tor-browser-proxy" ''
    #export TOR_BROWSER_PROFILE_DIR="$HOME/.tor-browser-proxy"
    #exec ${tor-browser-proxy}/bin/tor-browser --profile "$TOR_BROWSER_PROFILE_DIR" "$@"
    exec ${tor-browser-proxy}/bin/tor-browser "$@"
  '';
in {
  home.packages = with pkgs; [
    (nixtraLib.sandbox.wrapFirejail {
      executable = "${tor-browser-clearnet-wrapper}/bin/tor-browser-clearnet";
      profile = "tor-browser-other";
    })
    (nixtraLib.sandbox.wrapFirejail {
      executable = "${tor-browser-proxy-wrapper}/bin/tor-browser-proxy";
      profile = "tor-browser-other";
    })
    (nixtraLib.sandbox.wrapFirejail {
      executable = "${pkgs.tor-browser}/bin/tor-browser";
      profile = "tor-browser-main";
    })
    tor-browser
    tor-browser-clearnet-wrapper
    tor-browser-proxy-wrapper
  ];
}

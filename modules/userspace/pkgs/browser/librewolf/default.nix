{ config, profileSettings, pkgs, lib, nixtraLib, inputs, ... }:

# TODO: add violentmonkey scripts
# https://codeberg.org/Amm0ni4/bypass-all-shortlinks-debloated
# https://adsbypasser.github.io/

let
  extensionSettingsCommands = {
    new_temporary_container_tab = {
      precedenceList = [{
        id = "{c607c8df-14a7-4f28-894f-29e8722976af}";
        installDate = 1000;
        value = { shortcut = "Ctrl+T"; };
        enabled = true;
      }];
    };

    new_temporary_container_tab_current_url = {
      precedenceList = [{
        id = "{c607c8df-14a7-4f28-894f-29e8722976af}";
        installDate = 1000;
        value = { shortcut = "Ctrl+R"; };
        enabled = true;
      }];
    };
  };

  profileName = "default";

  userChrome = import ./theme2/userChrome.nix { inherit config lib; };
in {
  imports = [ ];

  programs.librewolf = {
    enable = true;

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
    };

    profiles = {
      ${profileName} = {
        isDefault = true;

        settings = {
          "image.animation_mode" = "once"; # better perf

          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "browser.sessionstore.max_resumed_crashes" =
            0; # Disable Session Restore feature
          "browser.sessionhistory.max_entries" = 10;
          "browser.sessionstore.debug.no_auto_updates" = true;
          "browser.sessionstore.disable_platform_collection" = true;
          "cookiebanners.service.mode.privateBrowsing" =
            2; # Block cookie banners in private browsing
          "cookiebanners.service.mode" = 2; # Block cookie banners
          "privacy.donottrackheader.enabled" = true;
          "privacy.fingerprintingProtection" = true;
          "privacy.resistFingerprinting" = true;
          "privacy.trackingprotection.emailtracking.enabled" = true;
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.fingerprinting.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "browser.privatebrowsing.autostart" = true;
          "browser.privatebrowsing.vpnpromourl" = "";
          "network.http.sendRefererHeader" = 0;
          "network.cookie.cookieBehavior" = 2;
          "browser.cache.memory.enable" = false;
          "browser.cache.disk.enable" = false;
          #"browser.chrome.site_icons" = false;
          "browser.chrome.site_icons" = true;
          "browser.shell.shortcutFavicons" = false;
          "geo.enabled" = false;
          "media.peerconnection.enabled" = false;
          "services.sync.prefs.sync.media.autoplay.default" = false;
          "messaging-system.rsexperimentloader.enabled" = false;
          "browser.translations.automaticallyPopup" = false;
          "browser.newtabpage.activity-stream.telemetry.structuredIngestion.endpoint" =
            "";
          "toolkit.telemetry.user_characteristics_ping.opt-out" = true;
          "browser.startup.couldRestoreSession.count" = 0;
          "browser.sessionstore.restore_tabs_lazily" = false;
          "browser.sessionstore.restore_on_demand" = false;
          "places.history.enabled" = false;
          "browser.download.manager.retention" = 0;
          "privacy.clearOnShutdown.downloads" = true;
          "privacy.clearOnShutdown.history" = true;
          "privacy.history.custom" = true;

          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.feeds.discoverystreamfeed" =
            false;

          "beacon.enabled" = false;

          "javascript.use_us_english_locale" = true;

          "network.dns.disableIPv6" = true;

          "browser.fixup.alternate.enabled" = false;
          "browser.urlbar.trimURLs" = false;
          "extensions.formautofill.available" = "off";
          "extensions.formautofill.creditCards.available" = false;
          "browser.urlbar.quicksuggest.scenario" = "history";
          "browser.sessionstore.resume_from_crash" = false;
          "browser.pagethumbnails.capturing_disabled" = true;

          "dom.security.https_only_mode" = true;
          "dom.security.https_only_mode_send_http_background_request" = false;
          "security.pki.sha1_enforcement_level" = 1;
          "network.http.referer.XOriginPolicy" = 2;

          "media.peerconnection.ice.no_host" = true;

          "privacy.partition.always_partition_third_party_non_cookie_storage.exempt_sessionstorage" =
            true;

          "extensions.Screenshots.disabled" = true;

          "network.cookie.lifetimePolicy" = 2;
          "privacy.clearOnShutdown.offlineApps" = true;
          "privacy.clearOnShutdown.openWindows" = true;

          "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = true;
          "privacy.clearOnShutdown_v2.formdata" = true;
          "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" = true;
          "privacy.clearOnShutdown_v2.siteSettings" = true;

          "privacy.firstparty.isolate" = true;

          # Get rid of search suggestions; distraction-free browsing
          "browser.urlbar.suggest.searches" = false;
          "browser.urlbar.suggest.history" = false;
          "browser.urlbar.suggest.bookmark" = false;
          "browser.urlbar.suggest.openpage" = false;
          "browser.urlbar.suggest.topsites" = false;
          "browser.urlbar.autoFill" = false;
        } // (if config.nixtra.display.themeType == "dark" then {
          "ui.systemUsesDarkTheme" = true;
          "layout.css.prefers-color-scheme.content-override" = 0;
          "browser.devedition.theme.enabled" = true;
          "devtools.theme" = "dark";
        } else
          { }) # In case of websites not adhering to system theme
          // {
            #  NATURAL SMOOTH SCROLLING V4 "SHARP" - AveYo, 2020-2022             preset     [default]
            #  copy into firefox/librewolf profile as user.js, add to existing, or set in about:config
            "general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS" = 12;
            "general.smoothScroll.msdPhysics.enabled" = true;
            "general.smoothScroll.msdPhysics.motionBeginSpringConstant" = 200;
            "general.smoothScroll.msdPhysics.regularSpringConstant" = 250;
            "general.smoothScroll.msdPhysics.slowdownMinDeltaMS" = 25;
            "general.smoothScroll.msdPhysics.slowdownMinDeltaRatio" = "2.0";
            "general.smoothScroll.msdPhysics.slowdownSpringConstant" = 250;
            "general.smoothScroll.currentVelocityWeighting" = "1.0";
            "general.smoothScroll.stopDecelerationWeighting" = "1.0";

            # adjust multiply factor for mousewheel - or set to false if scrolling is way too fast
            "mousewheel.system_scroll_override.horizontal.factor" = 200;
            "mousewheel.system_scroll_override.vertical.factor" = 200;
            "mousewheel.system_scroll_override_on_root_content.enabled" = true;
            "mousewheel.system_scroll_override.enabled" = true;

            # adjust pixels at a time count for mousewheel - cant do more than a page at once if <100
            "mousewheel.default.delta_multiplier_x" = 100;
            "mousewheel.default.delta_multiplier_y" = 100;
            "mousewheel.default.delta_multiplier_z" = 100;

            #  this preset will reset couple extra variables for consistency
            "apz.allow_zooming" = true;
            "apz.force_disable_desktop_zooming_scrollbars" = false;
            "apz.paint_skipping.enabled" = true;
            "apz.windows.use_direct_manipulation" = true;
            "dom.event.wheel-deltaMode-lines.always-disabled" = false;
            "general.smoothScroll.durationToIntervalRatio" = 200;
            "general.smoothScroll.lines.durationMaxMS" = 150;
            "general.smoothScroll.lines.durationMinMS" = 150;
            "general.smoothScroll.other.durationMaxMS" = 150;
            "general.smoothScroll.other.durationMinMS" = 150;
            "general.smoothScroll.pages.durationMaxMS" = 150;
            "general.smoothScroll.pages.durationMinMS" = 150;
            "general.smoothScroll.pixels.durationMaxMS" = 150;
            "general.smoothScroll.pixels.durationMinMS" = 150;
            "general.smoothScroll.scrollbars.durationMaxMS" = 150;
            "general.smoothScroll.scrollbars.durationMinMS" = 150;
            "general.smoothScroll.mouseWheel.durationMaxMS" = 200;
            "general.smoothScroll.mouseWheel.durationMinMS" = 50;
            "layers.async-pan-zoom.enabled" = true;
            "layout.css.scroll-behavior.spring-constant" = "250";
            "mousewheel.transaction.timeout" = 1500;
            "mousewheel.acceleration.factor" = 10;
            "mousewheel.acceleration.start" = -1;
            "mousewheel.min_line_scroll_amount" = 5;
            "toolkit.scrollbox.horizontalScrollDistance" = 5;
            "toolkit.scrollbox.verticalScrollDistance" = 3;
          };

        extensions = {
          force = true;

          packages =
            with inputs.firefox-addons.packages.${profileSettings.arch};
            [
              ublock-origin
              stylus
              decentraleyes
              canvasblocker
              #clearcache
              clearurls
              cookie-autodelete
              return-youtube-dislikes
              mtab
              istilldontcareaboutcookies
              auto-tab-discard
              violentmonkey
              sponsorblock
              spoof-timezone
              temporary-containers
              multi-account-containers
              noscript
              nighttab
              redirector
              nopow
              #tranquility
              unpaywall
              #chameleon
            ] ++ (if config.nixtra.display.themeType == "dark" then
              [
                inputs.firefox-addons.packages.${profileSettings.arch}.darkreader
              ]
            else
              [ ]);

          # You can find extension options by looking at the storage.js
          # files of the desired one:
          # > find .librewolf/default -iname "*storage.js" | grep "$EXT_ID"
          # To find the ID of an extension, visit `about:support` and go to the
          # "Extensions" category.
          settings = {
            # U-Block Origin
            "uBlock0@raymondhill.net" = {
              force = true;
              settings = {
                selectedFilterLists = [
                  "ublock-filters"
                  "ublock-badware"
                  "ublock-privacy"
                  "ublock-unbreak"
                  "ublock-quick-fixes"
                  "easylist"
                  "easyprivacy"
                  "urlhaus-1"
                  "fanboy-cookiemonster"
                  "ublock-cookies-easylist"
                  "fanboy-social"
                  "fanboy-thirdparty_social"
                  "easylist-chat"
                  "easylist-newsletters"
                  "easylist-notifications"
                  "easylist-annoyances"
                  "ublock-annoyances"
                ];

                # https://github.com/AveYo/fox/blob/main/tweaked%20uBlock%20cfg%202024.03.22%20user.txt
                dynamicFilteringString = ''
                  * ajax.aspnetcdn.com * noop
                  * libs.baidu.com * noop
                  * lib.baomitu.com * noop
                  * apps.bdimg.com * noop
                  * cdn.bootcss.com * noop
                  * maxcdn.bootstrapcdn.com * noop
                  * netdna.bootstrapcdn.com * noop
                  * stackpath.bootstrapcdn.com * noop
                  * ajax.cloudflare.com * noop
                  * cdnjs.cloudflare.com * noop
                  * facebook.com * block
                  * use.fontawesome.com * noop
                  * google.com * noop
                  * ajax.googleapis.com * noop
                  * fonts.googleapis.com * noop
                  * mat1.gtimg.com * noop
                  * hcaptcha.com * noop
                  * code.jquery.com * noop
                  * ajax.microsoft.com * noop
                  * onclickgenius.com * block
                  * lib.sinaapp.com * noop
                  * unpkg.com * noop
                  * upcdn.b0.upaiyun.com * noop
                  * youtube.com * noop
                  * gitcdn.github.io * noop
                  * pagecdn.io * noop
                  * cdn.plyr.io * noop
                  * akamaiedge.net * noop
                  * cdn.bootcdn.net * noop
                  * cdn.css.net * noop
                  * facebook.net * block
                  * fbcdn.net * block
                  * cdn.jsdelivr.net * noop
                  * akamai-webcdn.kgstatic.net * noop
                  * ajax.loli.net * noop
                  * cdnjs.loli.net * noop
                  * fonts.loli.net * noop
                  * yastatic.net * noop
                  * vjs.zencdn.net * noop
                  * sdn.geekzu.org * noop
                  * cdn.staticfile.org * noop
                  * ajax.proxy.ustclug.org * noop
                  * yandex.st * noop
                  behind-the-scene * * noop
                  behind-the-scene * inline-script noop
                  behind-the-scene * 1p-script noop
                  behind-the-scene * 3p-script noop
                  behind-the-scene * 3p-frame noop
                  behind-the-scene * image noop
                  behind-the-scene * 3p noop
                  facebook.com facebook.com * noop
                  facebook.com facebook.net * noop
                  facebook.com fbcdn.net * noop
                  github.com githubusercontent.com * noop
                  githubusercontent.com * 3p-frame noop
                  translate.google.com googleusercontent.com * noop
                  instagram.com * 3p-frame noop
                  instagram.com facebook.com * noop
                  instagram.com fbcdn.net * noop
                  onedrive.live.com * 3p-frame noop
                  reddit.com * 3p-frame noop
                  1337x.is * 3p-script block
                  imgur.com * 3p-script noop
                  imdb.com * 3p-script noop
                  * mozilla.com * noop
                  reddit.com redditstatic.com * noop
                  reddit.com reddit.map.fastly.net * noop
                  github.com * 3p-script noop
                  * gstatic.com * noop
                  * cdn.materialdesignicons.com * noop
                  * cdn.ravenjs.com * noop
                  forums.mydigitallife.net * * noop
                  1337x.to velocitycdn.com * block
                  1337x.to youradexchange.com * block
                  1337x.to vibuin.com * block
                  1337x.to crrepo.com * block
                  1337x.to * 3p-script block
                  1337x.st * 1p-script block
                  1337x.st * 3p-script block
                  * vo.aicdn.com * noop
                  * js.appboycdn.com * noop
                  * materialdesignicons.b-cdn.net * noop
                  * use.fontawesome.com.cdn.cloudflare.net * noop
                  * cdn.embed.ly.cdn.cloudflare.net * noop
                  * cdn.jsdelivr.net.cdn.cloudflare.net * noop
                  * ajax.loli.net.cdn.cloudflare.net * noop
                  * cdnjs.loli.net.cdn.cloudflare.net * noop
                  * fonts.loli.net.cdn.cloudflare.net * noop
                  * code.createjs.com * noop
                  * cdn.datatables.net * noop
                  * akamai-webcdn.kgstatic.net.edgesuite.net * noop
                  * cdn.embed.ly * noop
                  * sdn.inbond.gslb.geekzu.org * noop
                  * gstaticadssl.l.google.com * noop
                  * fonts.gstatic.com * noop
                  * cds.s5x3j6q5.hwcdn.net * noop
                  * apps.bdimg.jomodns.com * noop
                  * cdn.bootcss.com.maoyundns.com * noop
                  * cdn.bootcdn.net.maoyundns.com * noop
                  * cdn.mathjax.org * noop
                  * mscomajax.vo.msecnd.net * noop
                  * dualstack.osff.map.fastly.net * noop
                  * lib.baomitu.com.qh-cdn.com * noop
                  * iduwdjf.qiniudns.com * noop
                  * mat1.gtimg.com.tegsea.tc.qq.com * noop
                  * mathjax.rstudio.com * noop
                  * developer.n.shifen.com * noop
                  * lb.sae.sina.com.cn * noop
                  * gateway.cname.ustclug.org * noop
                  * wikimedia.org * noop
                  old.reddit.com ebayimg.com * noop
                  old.reddit.com twitch.tv * noop
                  old.reddit.com twitch.map.fastly.net * noop
                  * twitter.com * block
                  twitter.com twitter.com * noop
                  twitter.com t.co * noop
                  * thegrayzone.com * block
                  thegrayzone.com thegrayzone.com * block
                  www.bloomberg.com bloomberg.com * block
                  * bloomberg.com * block
                  * cloudflare.com * noop'';
                hostnameSwitchesString = ''
                  no-csp-reports: * true
                  no-large-media: behind-the-scene false'';
                userFilters = ''
                  ! 3rd party fonts
                  !*$font,third-party

                  ! imgur
                  imgur.com##canvas
                  imgur.com##.advertisement
                  imgur.com##.post-unification.right
                  imgur.com##.fixed.post-header
                  imgur.com##.Footer-wrapper
                  imgur.com##.Accolade-background
                  imgur.com##.Gallery-EngagementBar
                  imgur.com##.Gallery-Sidebar
                  imgur.com##.GalleryPopOverBanner
                  imgur.com##.GalleryVote-accoladesBridge
                  imgur.com##.BottomRecirc
                  imgur.com##.App-cover

                  ! twitch
                  ||twitch.tv/embed/*/chat$subdocument
                  twitch.tv##.chat-scrollable-area__message-container
                  twitch.tv##.top-bar

                  ! youtube
                  ||gstatic.com/youtube/img/promos$image
                  !youtube.com##.ytd-banner-promo-renderer
                  youtube.com##.ytp-pause-overlay
                  youtube.com##.ytp-title-fullerscreen-link
                  youtube.com##.ytp-title-channel
                  youtube.com##.ytp-title-text
                  youtube.com##.ytp-chrome-top-buttons
                  youtube.com##.ytp-show-tiles
                  youtube.com##.ytp-ce-covering-overlay
                  youtube.com##.ytp-ce-element-shadow
                  youtube.com##.ytp-ce-element-show
                  youtube.com##.ytp-title
                  ||youtube.com/live_chat
                  youtube.com###chatframe
                  youtube.com###chat
                  youtube.com###panels-full-bleed-container

                  ! google
                  ||cse.google.com/cse_v2/ads$subdocument

                  ! ghacks sellout
                  ghacks.net##.hentry,.home-posts,.home-category-post:not(:has-text(/Martin Brinkmann|Mike Turcotte|Ashwin/))

                  ! reddit
                  reddit.com##.promotedlink
                  reddit.com###eu-cookie-policy
                  reddit.com###header-img

                  ! reddit - constant 5% cpu / gpu penalty for the shitty awards icons - or set image.animation_mode once in about:config
                  ! ||redditstatic.com/gold/awards/icon/$image
                  ! ||redditstatic.com/silver/awards/icon/$image
                  ! ||thumbs.redditmedia.com/$image
                  ! ||preview.redd.it/award_images/$image
                  ! reddit.com##.awarding-icon
                  ! reddit.com##.awardings-bar

                  ! other
                  nytimes.com###gateway-content
                  imdb.com##.jw-reset.jw-controls
                  liquipedia.net##.navigation-not-searchable.content-ad-block
                  liquipedia.net##.is--sticky.navigation-not-searchable
                '';
              };
            };

            # Temporary Containers
            "{c607c8df-14a7-4f28-894f-29e8722976af}" = {
              force = true;
              settings = {
                preferences = {
                  automaticMode = {
                    enable = true;
                    newTab = "created";
                  };
                  replaceTabs = true;
                  keyboardShortcuts = {
                    AltC = true; # Ctrl T; open new page with container
                    AltO = true; # Ctrl R; reload page with new container
                  };
                };
              };
            };

            # Firefox Multi-Account Containers
            "@testpilot-containers" = {
              force = true;
              settings = { replaceTabEnabled = true; };
            };

            # Cookie AutoDelete
            "CookieAutoDelete@kennydo.com" = {
              force = true;
              settings = {
                settings = {
                  activeMode = true;
                  cacheCleanup = true;
                  cleanCookiesFromOpenTabsOnStartup = true;
                  cleanExpiredCookies = true;
                  contextMenus = true;
                  contextualIdentities = false;
                  contextualIdentitiesAutoRemove = true;
                  debugMode = false;
                  delayBeforeClean = "15";
                  discardedCleanup = true;
                  domainChangeCleanup = true;
                  enableGreyListCleanup = true;
                  enableNewVersionPopup = false;
                  indexedDBCleanup = true;
                  keepDefaultIcon = false;
                  localStorageCleanup = true;
                  manualNotifications = true;
                  notificationOnScreen = "3";
                  pluginDataCleanup = true;
                  serviceWorkersCleanup = true;
                  showNotificationAfterCleanup = false;
                  showNumOfCookiesInIcon = true;
                  siteDataEmptyOnEnable = true;
                  sizePopup = "16";
                  sizeSetting = "16";
                  statLogging = true;
                };
              };
            };

            # Redirector
            "redirector@einaregilsson.com" = {
              force = true;
              settings = {
                disabled = false;
                redirects = [
                  {
                    appliesTo = [ "main_frame" ];
                    description = "Reddit to Old Reddit";
                    disabled = false;
                    error = null;
                    exampleResult = "https://old.reddit.com/";
                    exampleUrl = "https://www.reddit.com/";
                    excludePattern = "";
                    grouped = false;
                    includePattern = "https://www.reddit.com/*";
                    patternDesc = "";
                    patternType = "W";
                    processMatches = "noProcessing";
                    redirectUrl = "https://old.reddit.com/$1";
                  }
                  {
                    appliesTo = [ "main_frame" ];
                    description = "X (Twitter) to Nitter instance";
                    disabled = false;
                    error = null;
                    exampleResult = "https://nitter.net/";
                    exampleUrl = "https://x.com/";
                    excludePattern = "";
                    grouped = false;
                    includePattern = "https://x.com/*";
                    patternDesc = "";
                    patternType = "W";
                    processMatches = "noProcessing";
                    redirectUrl = "https://nitter.net/$1";
                  }
                  {
                    appliesTo = [ "main_frame" ];
                    description = "Instagram to Imginn";
                    disabled = false;
                    error = null;
                    exampleResult = "https://imginn.com/";
                    exampleUrl = "https://www.instagram.com/";
                    excludePattern = "";
                    grouped = false;
                    includePattern = "https://www.instagram.com/*";
                    patternDesc = "";
                    patternType = "W";
                    processMatches = "noProcessing";
                    redirectUrl = "https://imginn.com/$1";
                  }
                  {
                    appliesTo = [ "main_frame" ];
                    description = "Old NixOS Wiki to New NixOS Wiki";
                    disabled = false;
                    error = null;
                    exampleResult = "https://nixos.wiki/";
                    exampleUrl = "https://nixos.wiki/";
                    excludePattern = "";
                    grouped = false;
                    includePattern = "https://nixos.wiki/*";
                    patternDesc = "";
                    patternType = "W";
                    processMatches = "noProcessing";
                    redirectUrl = "https://wiki.nixos.org/$1";
                  }
                ];
              };
            };

            # Stylus
            "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}" = {

            };

            # Tree Style Tab
            "treestyletab@piro.sakura.ne.jp" = {
              force = true;
              settings = {
                animationForce = true;
                autoAttach = true;
                autoAttachOnNewTabButtonAccelClick = 1;
                autoAttachOnNewTabCommand = 2;
                autoAttachOnOpenedFromExternal = 2;
                showExpertOptions = true;

                # encoded version of https://gist.github.com/theprojectsomething/6813b2c27611be03e67c78d936b0f760
                #chunkedUserStyleRules0 = builtins.readFile ./tst-theme-chunk.bin;
                chunkedUserStyleRules0 =
                  builtins.readFile ./theme2/chunks/1.bin;

                #chunkedUserStyleRules0 = builtins.readFile ./chunks/1.bin;
                #chunkedUserStyleRules1 = builtins.readFile ./chunks/2.bin;
                #chunkedUserStyleRules2 = builtins.readFile ./chunks/3.bin;
              };
            };

            #"{47bf427e-c83d-457d-9b3d-3db4118574bd}" = {
            #  force = true;
            #  settings = builtins.fromJSON (builtins.readFile ./nightTab.json);
            #};
          };
        };
        search = {
          force = true;
          default = "SearXNG"; # DuckDuckGo Lite
          privateDefault = "SearXNG"; # DuckDuckGo Lite
          order = [ "SearXNG" "DuckDuckGo Lite" "ddg" ];

          engines = {
            "SearXNG" = {
              urls = [{
                template = "http://127.0.0.1:8888/search?q={searchTerms}";
              }];
              definedAliases = [ "@searx" ];
            };
            "DuckDuckGo Lite" = {
              urls = [{
                template = "https://start.duckduckgo.com/lite?q={searchTerms}";
              }];
              definedAliases = [ "@ddgl" ];
            };
            "Nix Packages" = {
              urls = [{
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }];
              icon =
                "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };
            "NixOS Wiki" = {
              urls = [{
                template = "https://nixos.wiki/index.php?search={searchTerms}";
              }];
              icon = "https://nixos.wiki/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = [ "@nw" ];
            };
          };
        };
        inherit userChrome;
      };
    };
  };

  # `extension-settings.json` is needed to modify the shortcuts of
  # certain extensions, but NixOS does not have a declarative API
  # to modify it. In order to avoid breaking the user's active
  # configuration, it is injected at runtime post-build instead.
  home.activation.injectLibrewolfExtensionSettings = ''
    export PATH=${pkgs.jq}/bin:$PATH

    TARGET_DIR="$HOME/.librewolf/${profileName}"
    TARGET_FILE="$TARGET_DIR/extension-settings.json"

    mkdir -p $TARGET_DIR

    if [ ! -f "$TARGET_FILE" ]; then
      echo "{}" > "$TARGET_FILE"
    fi

    cp "$TARGET_FILE" "$TARGET_FILE.bak"

    jq '.commands |= (. // {} ) + ${
      builtins.toJSON extensionSettingsCommands
    }' $TARGET_FILE > $TARGET_FILE.tmp && mv $TARGET_FILE.tmp $TARGET_FILE
  '';

  home.file.".librewolf/default/chrome" = {
    source = ./theme2/chrome;
    executable = false;
    force = true;
    recursive = true;
  };

  # privileged script
  home.file.".librewolf/librewolf.overrides.cfg" = {
    source = ./librewolf.overrides.cfg;
    executable = true;
    force = true;
  };

  home.packages = [
    (nixtraLib.sandbox.wrapFirejail {
      executable = "${pkgs.librewolf-bin}/bin/librewolf";
      profile = "librewolf";
    })
  ];
}

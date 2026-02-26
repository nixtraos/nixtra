# Modified version of: https://tesar.tech/blog/2024-10-21_nix_os_zsh_autocomplete

{ config, lib, pkgs, ... }:

{
  config = lib.mkIf (config.nixtra.user.desktop == "flagship-hyprland") {
    home.packages = with pkgs; [ oh-my-posh git ];

    programs.zsh = {
      enable = true;
      plugins = [
        {
          name = "zsh-autocomplete"; # completes history, commands, etc.
          src = pkgs.fetchFromGitHub {
            owner = "marlonrichert";
            repo = "zsh-autocomplete";
            rev = "762afacbf227ecd173e899d10a28a478b4c84a3f";
            sha256 = "1357hygrjwj5vd4cjdvxzrx967f1d2dbqm2rskbz5z1q6jri1hm3";
          }; # e.g., nix-prefetch-url --unpack https://github.com/marlonrichert/zsh-autocomplete/archive/762afacbf227ecd173e899d10a28a478b4c84a3f.tar.gz
        }
        {
          name = "zsh-vi-man";
          src = pkgs.fetchFromGitHub {
            owner = "TunaCuma";
            repo = "zsh-vi-man";
            rev = "397b5440e14d9ee92d30d6ed508ce97dfe43c2ff";
            sha256 = "sha256-SEt61tHmwK7dowoY1Vjgv8mfgG7KrMz+/bGogjsfGIk=";
          };
        }
      ];

      oh-my-zsh = {
        enable = true;
        plugins = [ "z" ];
        extraConfig = ''
          # Required for autocomplete with box: https://unix.stackexchange.com/a/778868
          zstyle ':completion:*' completer _expand _complete _ignored _approximate _expand_alias
          zstyle ':autocomplete:*' default-context curcontext
          zstyle ':autocomplete:*' min-input 0

          setopt HIST_FIND_NO_DUPS

          autoload -Uz compinit
          compinit

          setopt autocd  # cd without writing 'cd'
          setopt globdots # show dotfiles in autocomplete list
        '';
      };

      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      history = { size = 10000; };

      # Extra configurations for Zsh
      initContent = ''
        # Oh-My-Posh initialization for Zsh
        eval "$(oh-my-posh init zsh --config /home/user/.config/zsh/shell.omp.json)"

        # zsh-autocomplete
        bindkey -M menuselect '^M' .accept-line # run code when selected completion

        # Vi mode with Esc
        #bindkey -v
      '';
    };

    xdg.configFile."zsh/shell.omp.json".text = ''
      {
        "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
        "blocks": [
          {
            "alignment": "left",
            "newline": true,
            "segments": [
              {
                "foreground": "#ffbebc",
                "leading_diamond": "<#ff70a6> \ue200 </>",
                "properties": {
                  "display_host": true
                },
                "style": "diamond",
                "template": "{{ .UserName }} <#ffffff>on</>",
                "type": "session"
              },
              {
                "foreground": "#bc93ff",
                "properties": {
                  "time_format": "Monday <#ffffff>at</> 3:04 PM"
                },
                "style": "diamond",
                "template": " {{ .CurrentDate | date .Format }} ",
                "type": "time"
              },
              {
                "foreground": "#ee79d1",
                "properties": {
                  "branch_icon": "\ue725 ",
                  "fetch_stash_count": true,
                  "fetch_status": true,
                  "fetch_upstream_icon": true,
                  "fetch_worktree_count": true
                },
                "style": "diamond",
                "template": " {{ .UpstreamIcon }}{{ .HEAD }}{{if .BranchStatus }} {{ .BranchStatus }}{{ end }}{{ if .Working.Changed }} \uf044 {{ .Working.String }}{{ end }}{{ if and (.Working.Changed) (.Staging.Changed) }} |{{ end }}{{ if .Staging.Changed }} \uf046 {{ .Staging.String }}{{ end }}{{ if gt .StashCount 0 }} \ueb4b {{ .StashCount }}{{ end }} ",
                "type": "git"
              }
            ],
            "type": "prompt"
          },
          {
            "alignment": "right",
            "segments": [
              {
                "foreground": "#a9ffb4",
                "style": "plain",
                "type": "text"
              },
              {
                "foreground": "#a9ffb4",
                "properties": {
                  "style": "dallas",
                  "threshold": 0
                },
                "style": "diamond",
                "template": " {{ .FormattedMs }}s <#ffffff>\ue601</>",
                "type": "executiontime"
              },
              {
                "properties": {
                  "root_icon": "\uf292 "
                },
                "style": "diamond",
                "template": " \uf0e7 ",
                "type": "root"
              },
              {
                "foreground": "#94ffa2",
                "style": "diamond",
                "template": " <#ffffff>MEM:</> {{ round .PhysicalPercentUsed .Precision }}% ({{ (div ((sub .PhysicalTotalMemory .PhysicalAvailableMemory)|float64) 1073741824.0) }}/{{ (div .PhysicalTotalMemory 1073741824.0) }}GB)",
                "type": "sysinfo"
              }
            ],
            "type": "prompt"
          },
          {
            "alignment": "left",
            "newline": true,
            "segments": [
              {
                "foreground": "#ffafd2",
                "leading_diamond": "<#00c7fc> \ue285 </><#ffafd2>{</>",
                "properties": {
                  "folder_icon": "\uf07b",
                  "folder_separator_icon": " \uebcb ",
                  "home_icon": "home",
                  "style": "agnoster_full"
                },
                "style": "diamond",
                "template": " \ue5ff {{ .Path }} ",
                "trailing_diamond": "<#ffafd2>}</>",
                "type": "path"
              },
              {
                "foreground": "#A9FFB4",
                "foreground_templates": ["{{ if gt .Code 0 }}#ef5350{{ end }}"],
                "properties": {
                  "always_enabled": true
                },
                "style": "plain",
                "template": " \ue286 ",
                "type": "status"
              }
            ],
            "type": "prompt"
          }
        ],
        "console_title_template": "{{ .Folder }}",
        "transient_prompt": {
          "background": "transparent",
          "foreground": "#FEF5ED",
          "template": "\ue285 "
        },
        "version": 3
      }
    '';
  };
}

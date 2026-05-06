# NOTE:
# - __raw means raw Lua code
# - Sources:
#   - https://discourse.nixos.org/t/embedded-syntax-highlighting-in-neovim-with-nix-multiline-strings/25809/6
#   - https://github.com/svrana/nix-home/blob/242bf7485cf64ae3579564c90d916f13078a6eda/home/config/nvim/queries/nix/injections.scm
#   - https://github.com/Ahwxorg/nixvim-config/blob/master/config/options.nix

{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:

let
  externalPlugins = import ./external-plugins.nix {
    inherit pkgs;
    inherit lib;
  };

  helpers = config.lib.nixvim;
in
{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  config = {
    nixtra.neovim.isNixvimUsed = true;

    home.packages = with pkgs; [
      nodePackages.npm
      unzip
      nixd # Nix
      ctags
      ripgrep
      pyright # Python
      vscode-langservers-extracted # HTML
      prettier
      tree-sitter
      black # Requirement by conform-nvim
      nixfmt-rfc-style
    ];

    programs.neovim.enable = lib.mkForce false;

    programs.nixvim = {
      enable = true;

      plugins = {
        # Essentials
        treesitter = {
          enable = true; # Syntax highlighting and code parsing
          nixGrammars = true;
          settings = {
            highlight.enable = true;
          };
        };
        lspconfig.enable = true; # Language Server Protocol configurations for IDE-like features
        cmp = {
          enable = true; # Autocompletion engine
          autoEnableSources = false; # Hide raw Lua warning
          settings = {
            performance = {
              fetching_timeout = 2000;
            };

            completion = {
              autocomplete = [
                ''"TextChanged"''
                ''"TextChangedI"''
              ];
            };

            window = {
              completion.border = "rounded";
              documentation.border = "rounded";
            };

            snippet = {
              expand = helpers.mkRaw ''
                function(args)
                  require("luasnip").lsp_expand(args.body)
                end
              '';
            };
            mapping = {
              "<CR>" = "cmp.mapping.confirm({ select = true })";
              "<C-Space>" = "cmp.mapping.complete()";
              "<Tab>" = "cmp.mapping.select_next_item()";
              "<S-Tab>" = "cmp.mapping.select_prev_item()";
            };
            sources = [
              {
                name = "minuet";
                priority = 100;
              }
              { name = "nvim_lsp"; }
              { name = "luasnip"; }
              { name = "buffer"; }
              { name = "path"; }
            ];
          };
        };
        cmp-buffer.enable = true;
        cmp-path.enable = true;
        cmp-nvim-lsp.enable = true;
        cmp_luasnip.enable = true;
        snacks = {
          # Set of small QoL plugins
          enable = true;
          settings = {
            terminal = {
              enable = true;
              stack = true;
            };
            util.enable = true;
            animate.enable = true;
            dim.enable = true;
            debug.enable = true;
            bufdelete.enable = true;
            scroll.enable = true; # Smooth scrolling
            lazygit.enable = true; # Fancy integrated Git UI
            words.enable = true; # Auto-show LSP references and navigate between them
          };
        };
        visual-multi.enable = true; # Multiple cursors
        navbuddy = {
          # Better symbol navigation
          enable = true;
          settings = {
            lsp = {
              auto_attach = true;
            };
          };
        };
        luasnip.enable = true; # Snippet engine
        clangd-extensions.enable = true; # Better clangd UX (inlay hints, AST)
        lazydev.enable = true;

        # LaTeX
        cmp-vimtex.enable = true;
        vimtex.enable = true;

        # Dependencies of navbuddy
        navic.enable = true;
        nui.enable = true;

        # Productivity Boosters
        commentary.enable = true; # Easy commenting/uncommenting code
        nvim-autopairs = {
          # Auto-close brackets, quotes, etc.
          enable = true;
        };
        markdown-preview.enable = true; # Markdown previewer

        # Git
        fugitive.enable = true; # Git integration
        gitsigns.enable = true; # Git change indicators in sign column

        # Formatting
        conform-nvim = {
          enable = true;
          settings = {
            format_on_save = {
              lsp_fallback = true;
              timeout_ms = 2000;
            };
            formatters_by_ft = {
              javascript = [ "prettier" ];
              typescript = [ "prettier" ];
              html = [ "prettier" ];
              python = [ "black" ]; # or ["isort" "black"]
              nix = [ "nixd" ];
              # for any filetype that doesn't have a specific formatter
              "_" = [ "trim_whitespace" ];
            };
          };
        };

        # UI & Appearance
        lazygit.enable = true;
        nvim-tree = {
          enable = true; # File explorer sidebar
          settings = {
            on_attach = helpers.mkRaw ''
              function(bufnr)
                local tree_api = require("nvim-tree.api")

                local function opts(desc)
                  return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                end

                -- default mappings
                tree_api.config.mappings.default_on_attach(bufnr)

                -- custom mappings
                vim.keymap.set('n', '?',     tree_api.tree.toggle_help, opts('Help'))
              end
            '';

            renderer = {
              icons = {
                show = {
                  git = true;
                  folder = true;
                  file = true;
                };
              };
            };

            disable_netrw = true;
            hijack_cursor = true;
            update_focused_file = {
              enable = true;
            };

            diagnostics = {
              enable = true;
              show_on_dirs = true;
              icons = {
                hint = "";
                info = "";
                warning = "";
                error = "";
              };
            };

            view = {
              width = 40;
              side = "left";
              signcolumn = "yes";
            };

            log = {
              enable = true;
              truncate = true;
              types = {
                diagnostics = true;
              };
            };
          };
        };
        ccc = {
          # Color picker
          enable = true;
          settings = {
            highlighter = {
              auto_enable = true;
              lsp = true;
            };
            auto_picker = true;
          };
        };
        render-markdown.enable = true; # Render markdown more nicely
        image = {
          # Image support
          enable = false;
          settings = {
            backend = "kitty";

            hijackFilePatterns = [
              "*.png"
              "*.jpg"
              "*.jpeg"
              "*.gif"
              "*.webp"
            ];

            maxHeightWindowPercentage = 25;

            # Critical for tmux compatibility
            tmuxShowOnlyInActiveWindow = true;

            integrations = {
              markdown = {
                enabled = true;
                downloadRemoteImages = true;
                clearInInsertMode = false; # Recommended for smoother editing
                filetypes = [
                  "markdown"
                  "vimwiki"
                  "mdx"
                ];
              };
            };

            # Performance and scaling tweaks
            maxWidth = null;
            maxHeight = null;
            windowOverlapClearEnabled = false;
            editorOnlyRenderWhenFocused = false;
          };
        };
        illuminate.enable = true; # Highlight words that match the one under the cursor
        noice.enable = true; # Fancier command window
        indent-blankline = {
          # Indentation guides
          enable = true;
          settings = {
            indent = {
              highlight = [ "NonText" ];
              char = "│";
            };
            scope = {
              enabled = true;
              highlight = [ "Function" ];
              show_start = false;
              show_end = false;
            };
          };
        };
        web-devicons.enable = true;
        # toggleterm = { # Terminal window
        #   enable = true;
        #   settings = {
        #     size = 15;
        #     open_mapping = "[[<C-t>]]";
        #     direction = "horizontal"; # bottom split
        #     start_in_insert = true;
        #     persist_size = true;
        #     shade_terminals = false;
        #     insert_mappings =
        #       true; # Whether the open mapping applies in insert mode
        #     terminal_mappings =
        #       true; # Whether the open mapping applies in terminal mode
        #   };
        # };
        lualine.enable = true; # Statusline
        telescope = {
          enable = true;
          # FIXME: Causes error
          extensions = {
            # disabled because they cause errors
            fzf-native.enable = false;
            ui-select.enable = false;
          };
        };
        colorizer = {
          # Color highlighter
          enable = true;
          settings = {
            event = "BufReadPre";
          };
        };
        alpha = {
          enable = true; # Greeter
          theme = "dashboard";
        };
        bufferline = {
          # Open file viewer
          enable = true;
          settings = {
            options = {
              always_show_bufferline = true;
              offsets = [
                {
                  filetype = "NvimTree";
                  text = "File Explorer";
                  text_align = "left";
                }
              ];
              show_close_icon = false;
              show_buffer_close_icons = false;
              separator_style = "thin";
            };
          };
        };
        treesitter-context = {
          enable = true; # Show code context
          settings = {
            separator = "─"; # Useful for transparent windows
          };
        };

        # # Aesthetics
        smear-cursor = {
          # Animated cursor
          enable = true;
          settings = {
            cursor_color = "none";
            hide_target_hack = true;
            never_draw_over_target = true;
            smear_insert_mode = true;
          };
        };
        lint = {
          # Linting
          enable = true;
          lintersByFt = {
            text = [ "vale" ];
            json = [ "jsonlint" ];
            markdown = [ "vale" ];
            rst = [ "vale" ];
            ruby = [ "ruby" ];
            janet = [ "janet" ];
            inko = [ "inko" ];
            clojure = [ "clj-kondo" ];
            dockerfile = [ "hadolint" ];
            terraform = [ "tflint" ];
          };
        };
        which-key.enable = true; # Show possible keybindings after prefix
        todo-comments.enable = true; # Highlight TODO/FIXME comments
        nvim-surround.enable = true; # Add/change/delete surrounding delimiter pairs with ease

        # Debugging
        dap.enable = true; # Debug Adapter Protocol client
        trouble = {
          enable = true;
        };

        # Keyboard
        hardtime.enable = true; # Avoid repeating mistakes with key presses
        cmp-emoji.enable = true; # Have emojis like :smile or :heart be added

        # AI
        # TODO: add api key
        wtf.enable = true; # Find out what diagnostics mean and fix them automatically
        minuet = {
          enable = true;
          settings = {
            provider = "openai_fim_compatible";
            n_completions = 1;
            context_window = 512;
            auto_trigger_ft = [ ];

            provider_options = {
              openai_fim_compatible = {
                api_key = "TERM";
                name = "Ollama";
                endpoint = "http://localhost:11434/v1/completions";
                model = "qwen2.5-coder:7b";
                optional = {
                  max_tokens = 56;
                  top_p = 0.9;
                };
              };
            };

            virtualtext = {
              enable = true;
              keymap = {
                accept = "<A-y>"; # Alt + y to accept the suggestion
                dismiss = "<A-e>"; # Alt + e to clear the suggestion
                # These cycle through multiple suggestions if the LLM provides them
                prev = "<A-[>";
                next = "<A-]>";
              };
            };
          };
        };

        # aider = { # AI pair programming agent
        #   enable = true;
        #   settings = {
        #     cmd = "Aider";
        #     keys = helpers.mkRaw ''
        #       {
        #         { "<leader>a/", "<cmd>Aider toggle<cr>", desc = "Toggle Aider" },
        #         { "<leader>as", "<cmd>Aider send<cr>", desc = "Send to Aider", mode = { "n", "v" } },
        #         { "<leader>ac", "<cmd>Aider command<cr>", desc = "Aider Commands" },
        #         { "<leader>ab", "<cmd>Aider buffer<cr>", desc = "Send Buffer" },
        #         { "<leader>a+", "<cmd>Aider add<cr>", desc = "Add File" },
        #         { "<leader>a-", "<cmd>Aider drop<cr>", desc = "Drop File" },
        #         { "<leader>ar", "<cmd>Aider add readonly<cr>", desc = "Add Read-Only" },
        #         { "<leader>aR", "<cmd>Aider reset<cr>", desc = "Reset Session" },
        #         -- Example nvim-tree.lua integration if needed
        #         { "<leader>a+", "<cmd>AiderTreeAddFile<cr>", desc = "Add File from Tree to Aider", ft = "NvimTree" },
        #         { "<leader>a-", "<cmd>AiderTreeDropFile<cr>", desc = "Drop File from Tree from Aider", ft = "NvimTree" },
        #       }
        #     '';
        #   };
        # };
      };

      extraPlugins = with externalPlugins; [
        # Productivity Boosters
        eregex # PCRE-like regex

        # Formatting
        editorconfig # .editorconfig adherence

        # UI & Appearance
        regex-syntax

        # Aesthetics
        tabular

        # AI
        gen
      ];

      extraConfigLua = ''
        require("gen").setup({
          accept_map = "<c-y>",
          retry_map = "<c-r>",
          quit_map = "<esc>"
        })
      '';

      diagnostic.settings = {
        update_in_insert = true;
        severity_sort = true;
        float = {
          border = "rounded";
        };
      };

      lsp = {
        servers = {
          clangd.enable = true;
          pyright.enable = true;
          nixd.enable = true;
          html.enable = true;
          css.enable = true;
          ts_ls.enable = true;
          lua_ls.enable = true;
          cssls.enable = true;
          texlab.enable = true;
        };
      };

      highlight =
        let
          transparent = {
            ctermbg = "none";
            bg = "none";
          };
        in
        {
          Normal = transparent;
          NormalNC = transparent;
          VertSplit = transparent;
          StatusLine = transparent;
          StatusLineNC = transparent;
          LineNr = transparent;
          EndOfBuffer = transparent;
          SignColumn = transparent;
          NvimTreeNormal = transparent;
          NvimTreeNormalNC = transparent;
          NavbuddyNormal = transparent;
          NavbuddyBorder = transparent;
          NavbuddyTitle = transparent;
          TreesitterContext = transparent;
          TreesitterContextLineNumber = transparent;
          WhichKeyFloat = transparent;
          SnacksTerminalNormal = transparent;
          SnacksTerminalBorder = transparent;
          FloatBorder = transparent;
          NormalFloat = transparent;
          Pmenu = transparent;
          PmenuSbar = transparent;
          PmenuThumb = {
            bg = "#504945";
          };
        };

      autoGroups = {
        "remember_cursor_position" = {
          clear = true;
        };
        "LspFormatting" = { };
      };
      autoCmd = [
        # Remember the last position of the cursor in a file
        {
          group = "remember_cursor_position";
          event = [ "BufReadPost" ];
          pattern = [ "*" ];
          callback = helpers.mkRaw ''
            function()
              local line = vim.fn.line("'\"")
              if line > 0 and line <= vim.fn.line("$") then
                vim.api.nvim_command("normal! g'\"")
              end
            end
          '';
        }

        # Set indentation for all programming filetypes
        {
          event = [ "FileType" ];
          pattern = [ "*" ];
          callback = helpers.mkRaw ''
            function()
              -- Use spaces instead of tabs
              vim.bo.expandtab = true;
              -- Number of spaces per indentation level
              vim.bo.shiftwidth = 2;
              -- Number of spaces to use for <Tab>
              vim.bo.tabstop = 2;
              -- Number of spaces for autoindent
              vim.bo.softtabstop = 2;
            end
          '';
        }
      ];

      globals = {
        eregex_force_case = true; # Force case sensitive like Perl ReGeX

        # Enable conceal in vim-markdown
        vim_markdown_conceal = true;
        vim_markdown_conceal_code_blocks = false;
      };

      opts = {
        # How concealed text is displayed
        conceallevel = 2; # 2 hides the text but shows substitute chars
        concealcursor = "nc"; # conceal applies in normal and command modes

        termguicolors = true; # Enable 24-bit RGB color in GUI

        # Search highlighting
        hlsearch = true;
        incsearch = true;

        wrap = true; # Enable line wrapping
        linebreak = true; # Break lines at word boundaries
        scrolloff = 8; # Keep 8 lines visible above and below the cursor

        # Avoid cluttering project with backup .ext~ files
        backup = true;
        backupdir = helpers.mkRaw ''vim.fn.stdpath("data") .. "/backup//"'';

        # Get better completion UX
        completeopt = [
          "menuone"
          "noselect"
          "noinsert"
        ];

        # Use system clipboard for y
        clipboard = "unnamedplus";

        # Encoding
        encoding = "utf-8";
        fileencoding = "utf-8";

        # Save undo history
        undofile = true;
        swapfile = true;
        autoread = true;

        # Highlight the current line for cursor
        cursorline = true;

        # Show line and column when searching
        ruler = true;

        # Show line numbers
        number = true;
        relativenumber = true;
      };

      # NOTE: To find what the leader key is, use `:echo mapleader`.
      keymaps =
        let
          optionsSilent = {
            silent = true;
          };
          optionsNoremap = {
            noremap = true;
          };
          optionsNoremapSilent = optionsSilent // optionsNoremap;
        in
        [
          # Navigation & LSP
          {
            mode = [
              "n"
              "v"
            ];
            key = "<C-S-P>";
            action = "<cmd>Legendary<CR>";
            options = optionsNoremapSilent;
          }
          {
            mode = "n";
            key = "<leader>r";
            action = "<cmd>Telescope lsp_references<CR>";
            options = optionsNoremapSilent // {
              desc = "List references";
            };
          }
          {
            mode = "n";
            key = "<leader>e";
            action = "<cmd>Telescope diagnostics<CR>";
            options = optionsNoremapSilent // {
              desc = "Show diagnostics";
            };
          }
          {
            mode = "n";
            key = "[d";
            action = "<cmd>Telescope diagnostics severity=error<CR>";
            options = optionsNoremapSilent // {
              desc = "Previous error";
            };
          }
          {
            mode = "n";
            key = "]d";
            action = "<cmd>Telescope diagnostics severity=warning<CR>";
            options = optionsNoremapSilent // {
              desc = "Next warning";
            };
          }
          # Telescope Search
          {
            mode = "n";
            key = "<C-S-p>";
            action = "<cmd>Telescope find_files<CR>";
            options = optionsNoremapSilent;
          }
          {
            mode = "n";
            key = "<C-S-f>";
            action = "<cmd>Telescope live_grep<CR>";
            options = optionsNoremapSilent;
          }
          {
            mode = "n";
            key = "<Esc>[1;6F"; # Kitty mapping
            action = "<cmd>Telescope live_grep<CR>";
            options = optionsNoremapSilent;
          }

          {
            mode = "n";
            key = "<leader>cp";
            action = "<cmd>CccPick<cr>";
            options.desc = "Pick Color";
          }

          {
            mode = "i"; # Insert mode
            key = "<C-a>"; # Manual trigger key
            action = helpers.mkRaw ''
              function()
                require('minuet').make_cmp_map()
              end
            '';
            options = {
              silent = true;
              desc = "Trigger Minuet AI Suggestion";
            };
          }

          # --- Buffer Management ---
          {
            mode = [
              "n"
              "i"
              "v"
            ];
            key = "<C-Tab>";
            action = "<cmd>BufferLineCycleNext<CR>";
            options.desc = "Next Buffer";
          }
          {
            mode = [
              "n"
              "i"
              "v"
            ];
            key = "<C-S-Tab>";
            action = "<cmd>BufferLineCyclePrev<CR>";
            options.desc = "Previous Buffer";
          }
          {
            mode = "n";
            key = "<C-x>";
            # Sequential commands combined
            action = "<cmd>BufferLineCyclePrev<CR><cmd>BufferLineCloseRight<CR>";
            options = optionsNoremapSilent;
          }

          # Terminal / Misc
          {
            mode = [
              "n"
              "t"
            ];
            key = "<leader>t";
            action = "<cmd>lua Snacks.terminal.toggle()<CR>";
            options = optionsNoremapSilent;
          }
          {
            mode = [
              "n"
              "t"
            ];
            key = "<leader>y";
            action = "<cmd>lua Snacks.terminal.open()<CR>";
            options = optionsNoremapSilent;
          }
          {
            mode = [
              "i"
              "t"
            ];
            key = "<Esc>";
            action = "<C-\><C-n>";
            options = optionsNoremapSilent;
          }

          # NvimTree Toggle
          {
            mode = "n";
            key = "<C-s>";
            action = helpers.mkRaw ''
              function()
                local api = require("nvim-tree.api")
                if api.tree.is_visible() then
                  api.tree.close()
                else
                  api.tree.open()
                end
              end
            '';
            options = optionsNoremapSilent // {
              desc = "Toggle NvimTree";
            };
          }
        ];
    };
  };
}

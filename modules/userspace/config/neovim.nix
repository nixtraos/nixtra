{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nodePackages.npm
    unzip
    nixd # Nix
    ctags
    ripgrep
    pyright # Python
    vscode-langservers-extracted # HTML
    prettier
  ];

  programs.neovim = {
    extraLuaConfig = # lua
      ''
        ----------------------
        --- PLUGIN MANAGER ---
        ----------------------

        local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
        if not vim.loop.fs_stat(lazypath) then
          vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable", -- latest stable release
            lazypath,
          })
        end
        vim.opt.rtp:prepend(lazypath)

        ---------------
        --- PLUGINS ---
        ---------------

        require("lazy").setup({
          -- Essentials
          "nvim-treesitter/nvim-treesitter", -- Syntax highlighting and code parsing
          "neovim/nvim-lspconfig",           -- Language Server Protocol configurations for IDE-like features
          "hrsh7th/nvim-cmp",                -- Autocompletion engine
          "nvim-lua/plenary.nvim",           -- Utility functions required by many plugins
          "hrsh7th/cmp-nvim-lsp",            -- The bridge between nvim-cmp and LSP capabilities
          "folke/snacks.nvim",               -- QoL plugins
          "mg979/vim-visual-multi",          -- Multiple cursors
          {
            "hasansujon786/nvim-navbuddy",        -- Better symbol navigation
            lsp = {
              auto_attach = true,
            },
            opts = { lsp = { auto_attach = true } },
            dependencies = { "neovim/nvim-lspconfig", "SmiteshP/nvim-navic", "MunifTanjim/nui.nvim" }
          },
          -- {
          --  "linrongbin16/gentags.nvim",     -- Tags generator/manager
          --   config = function()
          --     require('gentags').setup()
          --   end,
          -- },
          "l3mon4d3/luasnip",                -- Snippet engine
          "saadparwaiz1/cmp_luasnip",        -- Luasnip source for nvim-cmp
          "p00f/clangd_extensions.nvim",     -- Better clangd UX (inlay hints, AST)

          -- Productivity Boosters
          "tpope/vim-commentary",            -- Easy commenting/uncommenting code
          {
            "windwp/nvim-autopairs",         -- Auto-close brackets, quotes, etc.
            event = "InsertEnter",
            config = true,
          },
          "iamcco/markdown-preview.nvim",    -- Markdown previewer
          "othree/eregex.vim",               -- PCRE-like regex

          -- Git & Version Control
          "tpope/vim-fugitive",              -- Git integration
          "lewis6991/gitsigns.nvim",         -- Git change indicators in sign column

          -- Formatting
          "editorconfig/editorconfig-vim",   -- .editorconfig adherence

          -- UI & Appearance
          --"folke/tokyonight.nvim",         -- Tokyo Night color scheme
          {
            "nvim-tree/nvim-tree.lua",       -- File explorer sidebar
            dependencies = { "nvim-tree/nvim-web-devicons" },
          },
          {
            "akinsho/toggleterm.nvim",
            config = function()
              require("toggleterm").setup {
                size = 15,
                open_mapping = [[<C-t>]],
                direction = "horizontal", -- bottom split
                start_in_insert = true,
                persist_size = true,
                shade_terminals = false,
              }
            end
          },
          "nvim-lualine/lualine.nvim",     -- Statusline
          "Galicarnax/vim-regex-syntax",   -- PCRE syntax highlighting
          "nvim-telescope/telescope.nvim", -- Fancy interactive diagnostics windows
          {
            "catgoose/nvim-colorizer.lua",  -- Color highlighter
            event = "BufReadPre",
          },
          "goolord/alpha-nvim",            -- Greeter
          {
            "akinsho/bufferline.nvim",      -- Open file viewer
            dependencies = { "nvim-tree/nvim-web-devicons" },
          },
          "nvim-treesitter/nvim-treesitter-context",  -- Show code context

          -- Aesthetics
          {
            "sphamba/smear-cursor.nvim",             -- Animated cursor
            opts = {
              cursor_color = "none",
              hide_target_hack = true,
              never_draw_over_target = true,
              smear_insert_mode = true,
            }
          },
          "folke/which-key.nvim",                  -- Show possible keybindings after prefix
          "folke/todo-comments.nvim",              -- Highlight TODO/FIXME comments
          "lukas-reineke/indent-blankline.nvim",   -- Indent guides for Neovim
          "kylechui/nvim-surround",                -- Add/change/delete surrounding delimiter pairs with ease
          {
            "preservim/vim-markdown",
            dependencies = {"godlygeek/tabular"},
          },

          -- Debugging
          "mfussenegger/nvim-dap", -- Debug Adapter Protocol client

          -- Language-specific LSP servers and helpers
          {
            "williamboman/mason.nvim", -- Portable package manager for LSPs, DAP servers, linters, and formatters
            build = ":MasonUpdate"
          },
          "williamboman/mason-lspconfig.nvim", -- Bridges mason with nvim-lspconfig

          -- Optional: enhanced Lua support for Neovim
          {
            "folke/neodev.nvim", -- Neovim Lua development setup
            config = true,
          },

          -- Plugins with specific configuration
          --{
          --  "hrsh7th/nvim-cmp",
          --  event = "InsertEnter",                  -- lazy-load on Insert mode
          --  dependencies = { "hrsh7th/cmp-nvim-lsp" },
          --  config = function()
          --    -- Plugin-specific setup here
          --    require("cmp").setup {}
          --  end,
          --},

          -- More plugins...
        })

        -------------------------
        --- UTILITY FUNCTIONS ---
        -------------------------

        -- TODO

        ----------------------
        --- AUTOCOMPLETION ---
        ----------------------

        local cmp = require("cmp")
        local luasnip = require("luasnip")

        cmp.setup({
          completion = {
            autocomplete = { "TextChanged", "TextChangedI" },
          },
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          mapping = cmp.mapping.preset.insert({
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
            ["<C-Space>"] = cmp.mapping.complete(),
          }),
          sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "luasnip" },
            { name = "buffer" },
            { name = "path" },
          }),
        })

        ------------------
        --- NAVIGATION ---
        ------------------

        local navbuddy = require("nvim-navbuddy")
        local actions = require("nvim-navbuddy.actions")

        -- navbuddy.setup {
        --   mappings = {
        --   }
        -- }

        local tree_api = require "nvim-tree.api"

        local function tree_on_attach(bufnr)
          local function opts(desc)
            return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
          end

          -- default mappings
          tree_api.config.mappings.default_on_attach(bufnr)

          -- custom mappings
          vim.keymap.set('n', '?',     tree_api.tree.toggle_help, opts('Help'))
        end

        local tree = require("nvim-tree")
        tree.setup {
          on_attach = tree_on_attach,

          renderer = {
            icons = {
              show = {
                git = true,
                folder = true,
                file = true
              }
            }
          },

          disable_netrw = true,
          hijack_cursor = true,
          update_focused_file = {
            enable      = true,
          },

          diagnostics = {
            enable = true,
            show_on_dirs = true,
            icons = {
              hint = "",
              info = "",
              warning = "",
              error = "",
            },
          },

          view = {
            width = 40,
            side = 'left',
            signcolumn = 'yes',
          },

          log = {
            enable=true,
            truncate=true,
            types={
              diagnostics=true,
            },
          },
        }

        -----------------
        --- LSP SETUP ---
        -----------------

        local lspconfig = require("lspconfig")
        local util = require("lspconfig.util")

        local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

        local on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = augroup,
              buffer = bufnr,
              callback = function() vim.lsp.buf.format({ bufnr = bufnr }) end,
            })
          end
        end

        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        lspconfig.pyright.setup{
          cmd = { "pyright-langserver", "--stdio" },
          root_dir = util.root_pattern("pyproject.toml", "setup.cfg", "setup.py", "requirements.txt", ".git"),
          on_attach = function(client, bufnr)
            -- if you use null-ls or external formatters, avoid server formatting
            client.server_capabilities.documentFormattingProvider = false
            if on_attach then on_attach(client, bufnr) end
          end,
          capabilities = capabilities,
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",      -- "off" | "basic" | "strict"
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
              }
            }
          }
        }

        lspconfig.ts_ls.setup{
          cmd = { "typescript-language-server", "--stdio" },
          root_dir = util.root_pattern("package.json", "tsconfig.json", ".git"),
          on_attach = on_attach,
          capabilities = capabilities,
        }

        lspconfig.html.setup{
          -- filetypes default to { "html" } but you can add templating types if needed
          root_dir = util.root_pattern("package.json", ".git"),
          on_attach = function(client, bufnr)
            -- disable server formatting if you use prettier/formatter via null-ls
            client.server_capabilities.documentFormattingProvider = false
            if on_attach then on_attach(client, bufnr) end
          end,
          capabilities = capabilities,
          settings = {
            html = {
              suggest = { html5 = true },
              format = { enable = false }  -- set false if using prettier
            }
          }
        }

        local clangd_cmd = { "clangd" }

        lspconfig.clangd.setup{
          cmd = vim.list_extend(clangd_cmd, {
            "--background-index",
            "--clang-tidy",
            "--completion-style=detailed",
            "--header-insertion=never",
          }),
          root_dir = util.root_pattern("compile_commands.json", "compile_flags.txt", ".git"),
          on_attach = on_attach,
          capabilities = capabilities,
        }

        local nixd_cmd = { "nixd" }
        lspconfig.nixd.setup {
          cmd = vim.list_extend(nixd_cmd, {
          }),
          root_dir = util.root_pattern("flake.nix", "shell.nix", ".git"),
          on_attach = on_attach,
          capabilities = capabilities,
        }

        -- require("mason").setup()
        -- require("mason-lspconfig").setup({
        --   ensure_installed = { "clangd", "pyright", "rust_analyzer", "lua_ls" },
        -- })

        -- Set indentation for all programming filetypes
        vim.api.nvim_create_autocmd("FileType", {
          pattern = { "*" }, -- apply to all filetypes
          callback = function()
            -- Use spaces instead of tabs
            vim.bo.expandtab = true
            -- Number of spaces per indentation level
            vim.bo.shiftwidth = 2
            -- Number of spaces to use for <Tab>
            vim.bo.tabstop = 2
            -- Number of spaces for autoindent
            vim.bo.softtabstop = 2
          end,
        })

        -------------
        --- LOOKS ---
        -------------

        vim.opt.termguicolors = true

        -- Transparency
        vim.cmd [[
          hi Normal ctermbg=none guibg=none
          hi NormalNC ctermbg=none guibg=none
          hi VertSplit ctermbg=none guibg=none
          hi StatusLine ctermbg=none guibg=none
          hi LineNr ctermbg=none guibg=none
          hi NonText ctermbg=none guibg=none
          hi NavbuddyNormal ctermbg=none guibg=none
          hi NavbuddyBorder ctermbg=none guibg=none
          hi NavbuddyTitle ctermbg=none guibg=none
        ]]

        -- Customize the appearance of the hover diagnostic float
        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
          border = "rounded",      -- Rounded border for the float
          focusable = false,       -- Don't let the hover float be focusable
          max_width = 80,          -- Maximum width of the hover window
          max_height = 20,         -- Maximum height of the hover window
          padding = { 1, 1 },      -- Padding inside the window
          winhighlight = "Normal:Normal,FloatBorder:DiagnosticInfo", -- Custom highlights for Normal and Border
        })

        require("bufferline").setup{
          options = {
            always_show_bufferline = true,
            offsets = {
              { filetype = "NvimTree", text = "File Explorer", text_align = "left" }
            },
            show_close_icon = false,
            show_buffer_close_icons = false,
            separator_style = "thin",
          }
        }


        -- Enable conceal in vim-markdown
        vim.g.vim_markdown_conceal = 1
        vim.g.vim_markdown_conceal_code_blocks = 0

        -- How concealed text is displayed
        vim.o.conceallevel = 2       -- 2 hides the text but shows substitute chars
        vim.o.concealcursor = "nc"   -- conceal applies in normal and command modes

        -------------------
        --- VIM OPTIONS ---
        -------------------

        vim.g.eregex_force_case = 1 -- Force case sensitive like Perl ReGeX

        -- Enable search highlighting
        vim.opt.hlsearch = true
        vim.opt.incsearch = true

        vim.opt.wrap = true      -- Enable line wrapping
        vim.opt.linebreak = true -- Break lines at word boundaries
        vim.opt.scrolloff = 8    -- Keep 8 lines visible above and below the cursor

        -- Remember the last position of the cursor in a file
        vim.api.nvim_create_augroup("remember_cursor_position", { clear = true })
        vim.api.nvim_create_autocmd("BufReadPost", {
          group = "remember_cursor_position",
          pattern = "*",
          callback = function()
            local line = vim.fn.line("'\"")
            if line > 0 and line <= vim.fn.line("$") then
              vim.api.nvim_command("normal! g'\"")
            end
          end
        })

        ----------------
        --- KEYBINDS ---
        ----------------

        -- To find what your leader key is, run :echo mapleader
        -- If it returns nothing, your leader is backslash

        vim.api.nvim_set_keymap('n', '<C-d>', '<cmd>lua require("nvim-navbuddy").open()<CR>', { noremap = true, silent = true }) -- Open navbuddy navigator

        -- Toggle error (LSP
        --vim.keymap.set('n', '<leader>e', function()
        --  vim.diagnostic.open_float()
        --end)
        --vim.keymap.set('n', '<leader>e', function()
        --  require('telescope.builtin').diagnostics({ bufnr = 0 })
        --end, { noremap = true, silent = true })

        vim.api.nvim_set_keymap('n', '<leader>r', '<cmd>Telescope lsp_references<CR>', { noremap = true, silent = true }) -- List references of functions etc
        vim.api.nvim_set_keymap("n", "<leader>e", "<cmd>Telescope diagnostics<CR>", { noremap = true, silent = true }) -- Show diagnostic
        vim.api.nvim_set_keymap('n', '[d', '<cmd>Telescope diagnostics severity=error<CR>', { noremap = true, silent = true }) -- Go to previous diagnostic
        vim.api.nvim_set_keymap('n', ']d', '<cmd>Telescope diagnostics severity=warning<CR>', { noremap = true, silent = true }) -- Go to next diagnostic
        -- vim.api.nvim_set_keymap("n", "<leader>e", "<cmd>lua vim.diagnostic.open_float()<CR>", { noremap = true, silent = true }) -- Show diagnostic
        -- vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', { noremap = true, silent = true })  -- Go to previous diagnostic
        -- vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', { noremap = true, silent = true })  -- Go to next diagnostic
        -- vim.api.nvim_set_keymap('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', { noremap = true, silent = true }) -- Populate location list with all diagnostics

        vim.api.nvim_set_keymap('n', '<C-S-p>', '<cmd>Telescope find_files<CR>', { noremap = true, silent = true }) -- Search through files by name (like Quick Open on VSCode)
        vim.api.nvim_set_keymap('n', '<C-S-f>', '<cmd>Telescope live_grep<CR>', { noremap = true, silent = true }) -- Search text across files
        vim.api.nvim_set_keymap('n', '<Esc>[1;6F', '<cmd>Telescope live_grep<CR>', { noremap = true, silent = true }) -- Search text across files (kitty mapping)

        vim.keymap.set('n', '<C-tab>', '<Cmd>BufferLineCycleNext<CR>', { silent=true }) -- Go to next file
        vim.keymap.set('n', '<C-S-tab>', '<Cmd>BufferLineCyclePrev<CR>', { silent=true }) -- Go to previous file
        vim.keymap.set('n', '<C-x>', function()
          vim.cmd('BufferLineCyclePrev')
          vim.cmd('BufferLineCloseRight')
        end, { noremap = true, silent = true })

        vim.api.nvim_set_keymap('n', '<C-a>', '<C-t>', { noremap = true, silent = true }) -- Used for terminal instead

        -- Toggle nvim-tree.lua
        vim.keymap.set("n", "<C-s>", function()
          local api = require "nvim-tree.api"

          if api.tree.is_visible() then
            api.tree.close()
          else
            api.tree.open()
          end
        end, { noremap = true, silent = true, desc = "Toggle NvimTree" })
      '';
  };
}

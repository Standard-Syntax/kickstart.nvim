-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  init.lua — Derek's Neovim Config (built on kickstart)              ║
-- ║                                                                      ║
-- ║  Languages: Python 3.13, TypeScript/JS, Svelte 5, Rust,             ║
-- ║             SQL, JSON, TOML, YAML, Markdown                         ║
-- ║  AI:        opencode via nickjvandyke/opencode.nvim (Snacks-native)  ║
-- ║  Toolchain: ruff · basedpyright · biome · prettier · taplo · sqls   ║
-- ╚══════════════════════════════════════════════════════════════════════╝

-- ── Leader key ───────────────────────────────────────────────────────────────
-- Must be set before plugins load (otherwise wrong leader is used).
vim.g.mapleader      = ' '
vim.g.maplocalleader = ' '

-- Nerd Font in use — enables icons throughout.
vim.g.have_nerd_font = true

-- ── Options ──────────────────────────────────────────────────────────────────
vim.o.number       = true
vim.o.relativenumber = true          -- relative numbers for fast jumps
vim.o.mouse        = 'a'
vim.o.showmode     = false           -- status line shows mode
vim.o.breakindent  = true
vim.o.undofile     = true
vim.o.ignorecase   = true
vim.o.smartcase    = true
vim.o.signcolumn   = 'yes'
vim.o.updatetime   = 250
vim.o.timeoutlen   = 300
vim.o.splitright   = true
vim.o.splitbelow   = true
vim.o.list         = true
vim.o.inccommand   = 'split'
vim.o.cursorline   = true
vim.o.scrolloff    = 10
vim.o.confirm      = true
vim.o.tabstop      = 2
vim.o.shiftwidth   = 2
vim.o.expandtab    = true
vim.o.pumheight    = 12             -- max items in completion menu
vim.o.foldcolumn   = '0'
vim.o.laststatus   = 3              -- single global statusline (avoids blank bar in splits)
vim.opt.listchars  = { tab = '» ', trail = '·', nbsp = '␣' }

-- Schedule after UiEnter to avoid startup time hit.
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- ── Diagnostics ───────────────────────────────────────────────────────────────
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort    = true,
  float            = { border = 'rounded', source = 'if_many' },
  underline        = { severity = { min = vim.diagnostic.severity.WARN } },
  virtual_text     = { prefix = '●' },
  virtual_lines    = false,
  jump             = { float = true },
}

-- ── Core keymaps ─────────────────────────────────────────────────────────────
vim.keymap.set('n', '<Esc>',         '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q',     vim.diagnostic.setloclist,       { desc = 'Diagnostic [Q]uickfix' })
vim.keymap.set('t', '<Esc><Esc>',    '<C-\\><C-n>',                   { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<C-h>',         '<C-w><C-h>',                    { desc = 'Move focus left' })
vim.keymap.set('n', '<C-l>',         '<C-w><C-l>',                    { desc = 'Move focus right' })
vim.keymap.set('n', '<C-j>',         '<C-w><C-j>',                    { desc = 'Move focus down' })
vim.keymap.set('n', '<C-k>',         '<C-w><C-k>',                    { desc = 'Move focus up' })

-- Buffer navigation
vim.keymap.set('n', '<S-h>',         '<cmd>bprevious<CR>',            { desc = 'Prev buffer' })
vim.keymap.set('n', '<S-l>',         '<cmd>bnext<CR>',                { desc = 'Next buffer' })

-- Save shortcut
vim.keymap.set({ 'n', 'i' }, '<C-s>', '<cmd>w<CR><Esc>',             { desc = 'Save file' })

-- ── Autocommands ─────────────────────────────────────────────────────────────
vim.api.nvim_create_autocmd('TextYankPost', {
  desc     = 'Highlight on yank',
  group    = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- ── lazy.nvim bootstrap ──────────────────────────────────────────────────────
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system {
    'git', 'clone', '--filter=blob:none', '--branch=stable',
    'https://github.com/folke/lazy.nvim.git', lazypath,
  }
  if vim.v.shell_error ~= 0 then error('Error cloning lazy.nvim:\n' .. out) end
end
vim.opt.rtp:prepend(lazypath)

-- ════════════════════════════════════════════════════════════════════════════
--  PLUGINS
-- ════════════════════════════════════════════════════════════════════════════
require('lazy').setup({

  -- ── Git ──────────────────────────────────────────────────────────────────
  {
    'NeogitOrg/neogit',
    dependencies = { 'nvim-lua/plenary.nvim', 'sindrets/diffview.nvim' },
    opts = {},
    keys = { { '<leader>gn', '<cmd>Neogit<CR>', desc = 'Neogit' } },
  },
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add    = { text = '▎' },
        change = { text = '▎' },
        delete = { text = '' },
      },
      current_line_blame = true,
      on_attach = function(bufnr)
        local gs = require 'gitsigns'
        local map = function(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end
        map('n', ']h', function() gs.nav_hunk 'next' end, { desc = 'Next Git hunk' })
        map('n', '[h', function() gs.nav_hunk 'prev' end, { desc = 'Prev Git hunk' })
        map('n', '<leader>hs', gs.stage_hunk,   { desc = '[H]unk [S]tage' })
        map('n', '<leader>hr', gs.reset_hunk,   { desc = '[H]unk [R]eset' })
        map('n', '<leader>hp', gs.preview_hunk, { desc = '[H]unk [P]review' })
        map('n', '<leader>hb', function() gs.blame_line { full = true } end, { desc = '[H]unk [B]lame' })
      end,
    },
  },

  -- ── Formatting (conform.nvim) ─────────────────────────────────────────────
  --
  --  Strategy per filetype:
  --    TypeScript / JS / JSON / JSONC:
  --      → biome-check when biome.json present in project root (fast, opinionated)
  --      → prettier/prettierd fallback when no biome.json
  --    Svelte:
  --      → prettier (svelte plugin) — biome doesn't support svelte yet
  --    Python:   ruff_format + ruff_organize_imports
  --    Rust:     rustfmt (via rustaceanvim LSP)
  --    SQL:      sql-formatter
  --    TOML:     taplo
  --    YAML:     prettier
  --    Markdown: prettier
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd   = { 'ConformInfo' },
    keys  = {
      {
        '<leader>cf',
        function() require('conform').format { async = true, lsp_format = 'fallback' } end,
        mode = '',
        desc = '[C]ode [F]ormat',
      },
    },
    ---@module 'conform'
    ---@type conform.setupOpts
    opts = {
      notify_on_error = false,
      default_format_opts = { timeout_ms = 1000, lsp_format = 'fallback' },
      format_on_save = function(bufnr)
        -- Disable auto-format for C/C++ (no house standard).
        local disable_ft = { c = true, cpp = true }
        if disable_ft[vim.bo[bufnr].filetype] then return nil end
        return { timeout_ms = 1000, lsp_format = 'fallback' }
      end,
      formatters_by_ft = {
        -- Python — ruff handles both formatting and import sorting.
        python          = { 'ruff_format', 'ruff_organize_imports' },

        -- Rust — rustaceanvim manages rustfmt via LSP; do not list here to avoid
        --        double-formatting. lsp_format = 'fallback' in default_format_opts covers it.

        -- Lua
        lua             = { 'stylua' },

        -- TypeScript / JavaScript:
        --   Try biome-check first (only runs when biome.json found via require_cwd).
        --   Fall back to prettierd → prettier.
        typescript      = { 'biome-check', 'prettierd', 'prettier', stop_after_first = true },
        typescriptreact = { 'biome-check', 'prettierd', 'prettier', stop_after_first = true },
        javascript      = { 'biome-check', 'prettierd', 'prettier', stop_after_first = true },
        javascriptreact = { 'biome-check', 'prettierd', 'prettier', stop_after_first = true },

        -- Svelte — prettier with the Svelte plugin.
        svelte          = { 'prettierd', 'prettier', stop_after_first = true },

        -- Data / config formats.
        json            = { 'biome-check', 'prettierd', 'prettier', stop_after_first = true },
        jsonc           = { 'biome-check', 'prettierd', 'prettier', stop_after_first = true },
        toml            = { 'taplo' },
        yaml            = { 'prettierd', 'prettier', stop_after_first = true },
        css             = { 'biome-check', 'prettierd', 'prettier', stop_after_first = true },

        -- Docs.
        markdown        = { 'prettierd', 'prettier', stop_after_first = true },
        ['markdown.mdx'] = { 'prettierd', 'prettier', stop_after_first = true },

        -- SQL — uses sql-formatter (npm: sql-formatter).
        sql             = { 'sql_formatter' },
      },
      formatters = {
        -- biome-check only runs when a biome.json / biome.jsonc is present at cwd.
        ['biome-check'] = { require_cwd = true },

        -- sql_formatter configuration.
        sql_formatter = {
          command = 'sql-formatter',
          args = { '--language', 'sql', '--indent', '2' },
        },
      },
    },
  },

  -- ── Navigation: flash.nvim ────────────────────────────────────────────────
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts  = {},
    keys  = {
      { 's', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end,        desc = 'Flash jump' },
      { 'S', mode = { 'n', 'x', 'o' }, function() require('flash').treesitter() end,  desc = 'Flash treesitter' },
    },
  },

  -- ── Editing helpers ───────────────────────────────────────────────────────
  {
    'echasnovski/mini.surround',
    opts = {
      mappings = {
        add = 'sa', delete = 'sd', replace = 'sr',
        find = 'sf', find_left = 'sF', highlight = 'sh', update_n_lines = 'sn',
      },
    },
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts  = { check_ts = true },
  },
  {
    'windwp/nvim-ts-autotag',   -- auto-close/rename HTML/JSX/Svelte/TSX tags
    event = { 'BufReadPost', 'BufNewFile' },
    opts  = {
      -- New API (v0.2+): per-filetype overrides live under `per_filetype`,
      -- global behaviour flags live at the top level of `opts`.
      options = {
        enable_close          = true,
        enable_rename         = true,
        enable_close_on_slash = false, -- prevents double-slash in Svelte/JSX
      },
    },
  },
  { 'NMAC427/guess-indent.nvim', opts = {} },

  -- ── Which-key ────────────────────────────────────────────────────────────
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    ---@module 'which-key'
    ---@type wk.Opts
    opts = {
      delay = 0,
      icons = { mappings = vim.g.have_nerd_font },
      spec  = {
        { '<leader>s',  group = '[S]earch' },
        { '<leader>t',  group = '[T]oggle' },
        { '<leader>h',  group = 'Git [H]unk', mode = { 'n', 'v' } },
        { '<leader>g',  group = '[G]it' },
        { '<leader>x',  group = 'Diagnostics / [X]' },
        { '<leader>c',  group = '[C]ode' },
        { '<leader>b',  group = '[B]uffer' },
        { '<leader>o',  group = '[O]pencode' },
        { '<leader>f',  group = '[F]ind' },
        { 'gr',         group = 'LSP Actions' },
      },
    },
  },

  -- ── Telescope ────────────────────────────────────────────────────────────
  --
  -- Kept as primary picker for LSP navigation and git history browsing.
  -- Snacks picker handles files, grep, and the file explorer.
  {
    'nvim-telescope/telescope.nvim',
    event        = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', cond = function() return vim.fn.executable 'make' == 1 end },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require('telescope').setup {
        extensions = {
          ['ui-select'] = { require('telescope.themes').get_dropdown() },
        },
      }
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'
      -- Search / files
      vim.keymap.set('n', '<leader>sh',  builtin.help_tags,                  { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk',  builtin.keymaps,                    { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf',  builtin.find_files,                 { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss',  builtin.builtin,                    { desc = '[S]earch [S]elect' })
      vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string,       { desc = '[S]earch [W]ord' })
      vim.keymap.set('n', '<leader>sg',  builtin.live_grep,                  { desc = '[S]earch [G]rep' })
      vim.keymap.set('n', '<leader>sd',  builtin.diagnostics,                { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr',  builtin.resume,                     { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.',  builtin.oldfiles,                   { desc = '[S]earch Recent' })
      vim.keymap.set('n', '<leader>sc',  builtin.commands,                   { desc = '[S]earch [C]ommands' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers,               { desc = '[ ] Buffers' })
      vim.keymap.set('n', '<leader>sn',  function() builtin.find_files { cwd = vim.fn.stdpath 'config' } end, { desc = '[S]earch [N]vim files' })
      vim.keymap.set('n', '<leader>/',   function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false })
      end, { desc = '[/] Fuzzy current buffer' })
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep { grep_open_files = true, prompt_title = 'Grep Open Files' }
      end, { desc = '[S]earch [/] Open Files' })

      -- LSP pickers wired on attach (see nvim-lspconfig config below)
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
        callback = function(event)
          local buf = event.buf
          vim.keymap.set('n', 'grr', builtin.lsp_references,            { buffer = buf, desc = '[G]oto [R]eferences' })
          vim.keymap.set('n', 'gri', builtin.lsp_implementations,       { buffer = buf, desc = '[G]oto [I]mplementation' })
          vim.keymap.set('n', 'grd', builtin.lsp_definitions,           { buffer = buf, desc = '[G]oto [D]efinition' })
          vim.keymap.set('n', 'gO',  builtin.lsp_document_symbols,      { buffer = buf, desc = 'Document Symbols' })
          vim.keymap.set('n', 'gW',  builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Workspace Symbols' })
          vim.keymap.set('n', 'grt', builtin.lsp_type_definitions,      { buffer = buf, desc = '[G]oto [T]ype Def' })
        end,
      })
    end,
  },

  -- ── LSP ──────────────────────────────────────────────────────────────────
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim',             opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim',                opts = {} },
      'saghen/blink.cmp',
      'b0o/schemastore.nvim',    -- required by jsonls settings below
    },
    config = function()
      -- ── on-attach: keymaps ──────────────────────────────────────────────
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            vim.keymap.set(mode or 'n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          map('grn', vim.lsp.buf.rename,       '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action,  '[C]ode [A]ction', { 'n', 'x' })
          map('grD', vim.lsp.buf.declaration,  '[G]oto [D]eclaration')
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method('textDocument/documentHighlight', event.buf) then
            local group = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, { buffer = event.buf, group = group, callback = vim.lsp.buf.document_highlight })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, { buffer = event.buf, group = group, callback = vim.lsp.buf.clear_references })
            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(e)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = e.buf }
              end,
            })
          end
        end,
      })

      -- Disable Ruff hover — basedpyright owns hover/docs.
      vim.api.nvim_create_autocmd('LspAttach', {
        group    = vim.api.nvim_create_augroup('disable-ruff-hover', { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == 'ruff' then
            client.server_capabilities.hoverProvider = false
          end
        end,
        desc = 'LSP: Disable hover for ruff (basedpyright owns it)',
      })

      -- ── Server configs ──────────────────────────────────────────────────
      ---@type table<string, vim.lsp.Config>
      local servers = {

        -- ── Lua ──────────────────────────────────────────────────────────
        lua_ls = {
          on_init = function(client)
            if client.workspace_folders then
              local path = client.workspace_folders[1].name
              if path ~= vim.fn.stdpath 'config' and
                (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
              then return end
            end
            client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
              runtime  = { version = 'LuaJIT' },
              workspace = {
                checkThirdParty = false,
                library = vim.tbl_extend('force', vim.api.nvim_get_runtime_file('', true), {
                  '${3rd}/luv/library', '${3rd}/busted/library',
                }),
              },
            })
          end,
          settings = { Lua = {} },
        },

        -- ── Python ───────────────────────────────────────────────────────
        -- basedpyright: type checking, go-to-def, hover docs, completions.
        -- Ruff owns linting and import organisation.
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode    = 'standard',
                autoSearchPaths     = true,
                useLibraryCodeForTypes = true,
              },
              disableOrganizeImports = true,
            },
          },
        },
        -- ruff: fast lint + import-org LSP (hover disabled above).
        ruff = {},

        -- ── TypeScript / JavaScript ───────────────────────────────────────
        -- vtsls: VS Code TS extension as LSP — better than tsserver for
        --   monorepos, import-on-move, refactors, and workspace support.
        --   The typescript-svelte-plugin injection allows vtsls to understand
        --   TS inside .svelte files.
        vtsls = {
          settings = {
            vtsls = {
              tsserver = {
                globalPlugins = {
                  {
                    name     = 'typescript-svelte-plugin',
                    -- Mason installs svelte-language-server at this path.
                    location = vim.fn.stdpath('data')
                      .. '/mason/packages/svelte-language-server'
                      .. '/node_modules/typescript-svelte-plugin',
                    enableForWorkspaceTypeScriptVersions = true,
                  },
                },
              },
            },
            typescript = {
              updateImportsOnFileMove = { enabled = 'always' },
              suggest                 = { completeFunctionCalls = true },
              inlayHints = {
                enumMemberValues        = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames          = { enabled = 'literals' },
                parameterTypes          = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes           = { enabled = false },
              },
            },
          },
        },

        -- ── Svelte ───────────────────────────────────────────────────────
        -- svelte-language-server handles component props, slot types,
        -- template type checking (Svelte 5 runes supported from v0.16+).
        svelte = {
          settings = {
            svelte = {
              plugin = {
                svelte = { defaultScriptLanguage = 'ts' },
              },
            },
          },
        },

        -- ── Biome (LSP mode) ──────────────────────────────────────────────
        -- Provides linting diagnostics for projects that have biome.json.
        -- Formatting is handled by conform (biome-check formatter).
        biome = {},

        -- ── SQL ──────────────────────────────────────────────────────────
        -- sqls: basic SQL LSP — completions, query execution.
        -- Configure connections in ~/.config/sqls/config.yml if needed.
        sqls = {},

        -- ── YAML ─────────────────────────────────────────────────────────
        yamlls = {
          settings = {
            yaml = {
              -- Disable built-in SchemaStore fetcher; schemas are provided by
              -- schemastore.nvim below, which is more current and caches locally.
              schemaStore = { enable = false, url = '' },
              schemas     = require('schemastore').yaml.schemas(),
              validate    = true,
              completion  = true,
              hover       = true,
            },
          },
        },

        -- ── JSON ─────────────────────────────────────────────────────────
        jsonls = {
          settings = {
            json = {
              schemas  = require('schemastore').json.schemas(),
              validate = { enable = true },
            },
          },
        },

        -- ── TOML ─────────────────────────────────────────────────────────
        -- taplo handles both TOML LSP features and formatting.
        taplo = {},

        -- ── Markdown ─────────────────────────────────────────────────────
        marksman = {},

        -- ── Rust ─────────────────────────────────────────────────────────
        -- Managed by rustaceanvim — must NOT be added here.
        rust_analyzer = { enabled = false },
      }

      -- Install Mason packages for servers + standalone tools.
      local ensure_installed = vim.tbl_keys(servers or {})
      -- rust-analyzer must come from rustup, not Mason.
      ensure_installed = vim.tbl_filter(function(s) return s ~= 'rust_analyzer' end, ensure_installed)
      vim.list_extend(ensure_installed, {
        -- Formatters (tools, not LSPs)
        'stylua',        -- Lua formatter
        'prettierd',     -- fast prettier daemon
        'taplo',         -- TOML formatter (also LSP above)
        -- LSPs installed via Mason
        'basedpyright',
        'ruff',
        'vtsls',
        'svelte-language-server',
        'sqls',
        'yaml-language-server',
        'json-lsp',
        'marksman',
        -- NOTE: biome LSP activates only when biome.json / biome.jsonc is present in project root.
        --       The biome binary is installed globally by Mason (biome package above via tbl_keys).
        --       For formatting, biome-check in conform also gate-checks require_cwd = true.
        -- NOTE: rust-analyzer → rustup component add rust-analyzer
        -- NOTE: sql-formatter → npm i -g sql-formatter
      })

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      for name, server in pairs(servers) do
        if server.enabled ~= false then
          vim.lsp.config(name, server)
          vim.lsp.enable(name)
        end
      end
    end,
  },

  -- ── Autocompletion: blink.cmp ─────────────────────────────────────────────
  {
    'saghen/blink.cmp',
    event   = 'VimEnter',
    version = '1.3.1',  -- pinned: '1.*' picks up a rendering regression in some 1.x builds
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build   = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then return end
          return 'make install_jsregexp'
        end)(),
        dependencies = { 'rafamadriz/friendly-snippets' },
        config = function()
          require('luasnip.loaders.from_vscode').lazy_load()
        end,
      },
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap     = { preset = 'default' },
      appearance = { nerd_font_variant = 'mono' },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 300 },
        ghost_text    = { enabled = false },  -- disabled: interacts with blink rendering bug
      },
      sources    = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
      snippets   = { preset = 'luasnip' },
      fuzzy      = { implementation = 'prefer_rust_with_warning' },
      signature  = { enabled = true },
    },
  },

  -- ── Colorscheme: tokyonight ───────────────────────────────────────────────
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    config   = function()
      require('tokyonight').setup {
        style     = 'night',
        dim_inactive = true,
        styles    = { comments = { italic = false } },
      }
      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },

  -- ── todo-comments ────────────────────────────────────────────────────────
  {
    'folke/todo-comments.nvim',
    event        = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts         = { signs = false },
  },

  -- ── mini.nvim ────────────────────────────────────────────────────────────
  {
    'nvim-mini/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      local statusline = require 'mini.statusline'
      statusline.setup {
        use_icons = vim.g.have_nerd_font,
        -- Don't render statusline on these buffer types
        set_vim_settings = true,
        content = {
          inactive = function() return '' end, -- blank inactive windows
        },
      }
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function() return '%2l:%-2v' end
    end,
  },

  -- ── Treesitter ───────────────────────────────────────────────────────────
  {
    'nvim-treesitter/nvim-treesitter',
    lazy   = false,
    branch = 'main',
    build  = ':TSUpdate',
    config = function()
      local parsers = {
        -- Core
        'bash', 'c', 'diff', 'html', 'lua', 'luadoc',
        'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc',
        -- Python
        'python',
        -- TypeScript / JS / Svelte
        'typescript', 'javascript', 'tsx', 'svelte',
        -- Rust
        'rust',
        -- SQL
        'sql',
        -- Config / data
        'toml', 'json', 'jsonc', 'yaml', 'css',
        -- Regex (useful inside TS/JS)
        'regex',
      }
      require('nvim-treesitter').install(parsers)

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local buf      = args.buf
          local filetype = args.match
          local language = vim.treesitter.language.get_lang(filetype)
          if not language then return end
          if not vim.treesitter.language.add(language) then return end
          vim.treesitter.start(buf, language)
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },

  -- ── Treesitter text objects ───────────────────────────────────────────────
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter-textobjects').setup {
        select = {
          enable   = true,
          lookahead = true,
          keymaps  = {
            ['af'] = '@function.outer', ['if'] = '@function.inner',
            ['ac'] = '@class.outer',    ['ic'] = '@class.inner',
            ['aa'] = '@parameter.outer', ['ia'] = '@parameter.inner',
          },
        },
        move = {
          enable    = true,
          set_jumps = true,
          goto_next_start     = { [']m'] = '@function.outer', [']]'] = '@class.outer' },
          goto_next_end       = { [']M'] = '@function.outer', [']['] = '@class.outer' },
          goto_previous_start = { ['[m'] = '@function.outer', ['[['] = '@class.outer' },
          goto_previous_end   = { ['[M'] = '@function.outer', ['[]'] = '@class.outer' },
        },
        swap = {
          enable        = true,
          swap_next     = { ['<leader>a']  = '@parameter.inner' },
          swap_previous = { ['<leader>A']  = '@parameter.inner' },
        },
      }
    end,
  },

  -- ── Rust: rustaceanvim ───────────────────────────────────────────────────
  -- Supercharged rust-analyzer. Manages its own LSP client — do NOT add
  -- rust_analyzer to the servers table above.
  -- Install: rustup component add rust-analyzer
  {
    'mrcjkb/rustaceanvim',
    version = '^9',
    lazy    = false,
  },

  -- ── Cargo.toml crate management ──────────────────────────────────────────
  {
    'saecki/crates.nvim',
    event = { 'BufRead Cargo.toml' },
    opts  = {},
  },

  -- ── Diagnostics: trouble.nvim ─────────────────────────────────────────────
  {
    'folke/trouble.nvim',
    opts = {},
    cmd  = 'Trouble',
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>',                         desc = 'Diagnostics (Trouble)' },
      { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',            desc = 'Buffer Diagnostics (Trouble)' },
      { '<leader>xs', '<cmd>Trouble symbols toggle focus=false<cr>',                 desc = 'Symbols (Trouble)' },
      { '<leader>xl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',  desc = 'LSP Defs/Refs (Trouble)' },
      { '<leader>xq', '<cmd>Trouble qflist toggle<cr>',                              desc = 'Quickfix (Trouble)' },
    },
  },

  -- ── QoL + File Explorer: snacks.nvim ─────────────────────────────────────
  --
  --  Snacks replaces several individual plugins:
  --    • snacks.explorer  → file tree sidebar (no neo-tree needed)
  --    • snacks.picker    → fast file / grep / buffer picker (complements Telescope)
  --    • snacks.notifier  → better notifications
  --    • snacks.lazygit   → lazygit float
  --    • snacks.terminal  → managed terminal splits/floats (used by opencode.nvim)
  --    • snacks.words     → LSP word reference jumping
  --    • snacks.gitbrowse → open file on GitHub
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy     = false,
    ---@type snacks.Config
    opts = {
      bigfile   = { enabled = true },
      notifier  = { enabled = true, timeout = 3000 },
      lazygit   = { enabled = true },
      gitbrowse = { enabled = true },
      quickfile = { enabled = true },
      words     = { enabled = true },
      input     = { enabled = true },
      scratch   = { enabled = true },
      terminal  = { enabled = true },    -- opencode.nvim uses this
      -- ── File Explorer ───────────────────────────────────────────────────
      -- A sidebar file tree with git status + diagnostics. Replaces neo-tree.
      explorer = {
        enabled      = true,
        tree         = true,
        git_status   = true,
        git_untracked = true,
        diagnostics  = true,
        watch        = true,
        follow_file  = true,
        auto_close   = false,
        layout       = { preset = 'sidebar', preview = false },
      },
      -- ── Picker ─────────────────────────────────────────────────────────
      picker = {
        enabled = true,
        -- Use ripgrep for grep (respects your rg preference).
        grep = { cmd = 'rg' },
      },
      -- ── Dashboard ───────────────────────────────────────────────────────
      dashboard = {
        enabled = true,
        sections = {
          { section = 'header' },
          { section = 'keys',   gap = 1, padding = 1 },
          { section = 'recent_files', title = 'Recent', gap = 1, padding = 1 },
          { section = 'startup' },
        },
      },
    },
    keys = {
      -- File explorer (sidebar)
      { '<leader>e',   function() Snacks.explorer() end,                desc = 'File [E]xplorer' },
      -- Picker: files / grep / buffers
      { '<leader>ff',  function() Snacks.picker.files() end,            desc = '[F]ind [F]iles' },
      { '<leader>fg',  function() Snacks.picker.git_files() end,        desc = '[F]ind [G]it Files' },
      { '<leader>fr',  function() Snacks.picker.recent() end,           desc = '[F]ind [R]ecent' },
      { '<leader>fp',  function() Snacks.picker.projects() end,         desc = '[F]ind [P]rojects' },
      -- Git
      { '<leader>gg',  function() Snacks.lazygit() end,                 desc = 'Lazy[G]it' },
      { '<leader>gB',  function() Snacks.gitbrowse() end,               desc = '[G]it [B]rowse', mode = { 'n', 'v' } },
      { '<leader>gb',  function() Snacks.picker.git_branches() end,     desc = '[G]it [B]ranches' },
      { '<leader>gl',  function() Snacks.picker.git_log() end,          desc = '[G]it [L]og' },
      { '<leader>gs',  function() Snacks.picker.git_status() end,       desc = '[G]it [S]tatus' },
      -- Buffer management
      { '<leader>bd',  function() Snacks.bufdelete() end,               desc = '[B]uffer [D]elete' },
      -- Scratch buffers
      { '<leader>.',   function() Snacks.scratch() end,                 desc = 'Scratch Buffer' },
      -- LSP word jumping — using ]r/[r to avoid conflict with treesitter-textobjects ]] / [[
      { ']r',          function() Snacks.words.jump(vim.v.count1) end,  desc = 'Next LSP Reference', mode = { 'n', 't' } },
      { '[r',          function() Snacks.words.jump(-vim.v.count1) end, desc = 'Prev LSP Reference', mode = { 'n', 't' } },
      -- Notification history
      { '<leader>un',  function() Snacks.notifier.show_history() end,   desc = 'Notification History' },
      -- Terminal toggle
      { '<leader>tt',  function() Snacks.terminal.toggle() end,          desc = '[T]erminal [T]oggle' },
      { '<C-\\>',      function() Snacks.terminal.toggle() end,          desc = 'Toggle terminal', mode = { 'n', 't' } },
    },
  },

  -- ── opencode.nvim ────────────────────────────────────────────────────────
  --
  --  Uses Snacks.terminal to open opencode as a TUI sidebar.
  --  nickjvandyke/opencode.nvim: lightweight Snacks-native bridge.
  --
  --  Requires: opencode CLI available on PATH.
  --    NixOS: add opencode to your flake devShell / system packages.
  --    npm:   npm i -g opencode-ai  (or bun add -g opencode-ai)
  --
  --  Keymaps:
  --    <leader>oo → toggle opencode TUI sidebar (right split)
  --    <leader>oa → ask opencode (prompt input)
  --    <leader>ov → send visual selection to opencode
  {
    'nickjvandyke/opencode.nvim',
    lazy = false,
    config = function()
      -- The plugin reads configuration from vim.g.opencode_opts.
      ---@type opencode.Opts
      local opencode_cmd = 'oco --port'

      ---@type snacks.terminal.Opts
      local snacks_win = {
        win = { position = 'right', width = 0.38, enter = false },
      }

      vim.g.opencode_opts = {
        server = {
          start = function()
            require('snacks.terminal').open(opencode_cmd, snacks_win)
          end,
        },
      }
    end,
    keys = {
      -- Toggle the opencode TUI sidebar.
      {
        '<leader>oo',
        function()
          require('snacks.terminal').toggle('oco --port', {
            win = { position = 'right', width = 0.38 },
          })
        end,
        desc = '[O]pencode [O]pen/toggle',
      },
      -- Ask: quick prompt input (uses the plugin's in-process LSP input).
      { '<leader>oa', function() require('opencode').ask() end,      desc = '[O]pencode [A]sk' },
      -- Send visual selection to opencode.
      { '<leader>ov', function() require('opencode').ask() end,      mode = 'v', desc = '[O]pencode [V]isual ask' },
      -- Open opencode command palette.
      { '<leader>oc', function() require('opencode').commands() end, desc = '[O]pencode [C]ommands' },
    },
  },

  -- ── Code outline: aerial.nvim ─────────────────────────────────────────────
  {
    'stevearc/aerial.nvim',
    opts         = {},
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    keys         = { { '<leader>cs', '<cmd>AerialToggle<CR>', desc = '[C]ode [S]ymbols (Aerial)' } },
  },

  -- ── Indent guide: indent-blankline ───────────────────────────────────────
  {
    'lukas-reineke/indent-blankline.nvim',
    main  = 'ibl',
    event = 'BufReadPost',
    opts  = {
      indent = { char = '│' },
      scope  = { enabled = true },
    },
  },

  -- ── Bufferline ───────────────────────────────────────────────────────────
  --
  -- Tabs across the top showing open buffers.
  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event   = 'VeryLazy',
    opts    = {
      options = {
        diagnostics        = 'nvim_lsp',
        always_show_bufferline = false,
        offsets = {
          {
            filetype   = 'snacks_layout_box',
            text       = 'Explorer',
            highlight  = 'Directory',
            text_align = 'left',
          },
        },
      },
    },
  },

  -- ── Comment.nvim ─────────────────────────────────────────────────────────
  --
  -- gcc / gc + motion to toggle comments. Svelte / TSX aware.
  {
    'numToStr/Comment.nvim',
    event = 'BufReadPost',
    opts  = {},
  },

}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘', config = '🛠', event = '📅', ft = '📂', init = '⚙',
      keys = '🗝', plugin = '🔌', runtime = '💻', require = '🌙',
      source = '📄', start = '🚀', task = '📌', lazy = '💤 ',
    },
  },
})

-- vim: ts=2 sts=2 sw=2 et

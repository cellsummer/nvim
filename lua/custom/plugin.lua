-- lua/custom/plugin.lua
-- Migrated from vim-plug plugins in _vimrc
-- Note: vim-surround excluded (replaced by mini.surround in init.lua)
--       vim-zeef / fzf / fzf.vim excluded (replaced by telescope in init.lua)
--       Disable native LSP stack in init.lua to avoid conflicts with coc.nvim

---@module 'lazy'
---@type LazySpec
return {
  -- LSP / autocompletion via coc.nvim
  {
    'neoclide/coc.nvim',
    branch = 'release',
    -- coc extensions: install via :CocInstall or list them here
    -- init = function()
    --   vim.g.coc_global_extensions = { 'coc-pyright', 'coc-lua', 'coc-json' }
    -- end,
  },

  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true

    -- use opts = {} for passing setup options
    -- this is equivalent to setup({}) function
  },

  -- Show search match count (e.g. "3/10") in the command line
  'google/vim-searchindex',

  -- Easy alignment: ga<motion> or ga in visual mode
  {
    'junegunn/vim-easy-align',
    keys = {
      { 'ga', '<Plug>(EasyAlign)', mode = { 'n', 'x' }, desc = 'Easy Align' },
    },
  },

  -- Inline color highlighting (#rrggbb, rgb(), etc.)
  {
    'norcalli/nvim-colorizer.lua',
    opts = {},
  },

  -- Clever f/t/F/T: highlights targets, repeat with f/t
  'rhysd/clever-f.vim',

  -- Git integration (:Git ...)
  'tpope/vim-fugitive',

  -- Bitbucket support for vim-fugitive (:GBrowse on Bitbucket URLs)
  {
    'tommcdo/vim-fubitive',
    dependencies = { 'tpope/vim-fugitive' },
    init = function()
      vim.g.fubitive_domain_pattern = 'bitbucket\\.us\\.aegon\\.com'
      vim.g.fubitive_default_protocol = 'http://'
    end,
  },

  -- Surround: cs"' ds" ysiw) etc.
  'tpope/vim-surround',

  -- Enable repeating plugin maps with .
  'tpope/vim-repeat',

  -- Readline-style bindings in insert and command mode (C-a, C-e, C-d, etc.)
  'tpope/vim-rsi',

  -- Auto-change working directory to project root
  'airblade/vim-rooter',

  -- Floating terminal
  {
    'voldikss/vim-floaterm',
    keys = {
      { '<C-/>', desc = 'Toggle floaterm' },
      { '<C-q>', desc = 'Kill floaterm' },
    },
    init = function()
      vim.g.floaterm_keymap_toggle = '<C-/>'
      vim.g.floaterm_keymap_kill = '<C-q>'
      vim.g.floaterm_shell = 'cmd'
      vim.g.floaterm_opener = 'edit'
      vim.g.floaterm_wintype = 'vsplit'
      vim.g.floaterm_width = 0.33
    end,
  },

  -- Colorschemes (cellsummer/vim-colors includes predawn)
  {
    'cellsummer/vim-colors',
    priority = 1000,
    config = function()
      vim.o.termguicolors = true
      vim.g.predawn_disable_italic = 1
      vim.cmd.colorscheme 'predawn'

      -- Float/popup highlight overrides (predawn doesn't define these)
      local hl = vim.api.nvim_set_hl
      hl(0, 'NormalFloat',      { fg = '#F1F1F1', bg = '#232323' })
      hl(0, 'FloatBorder',      { fg = '#777777', bg = '#232323' })
      hl(0, 'FloatTitle',       { fg = '#F18260', bg = '#232323', bold = true })
      hl(0, 'SnacksPickerDir',  { fg = '#92BFBF' })

      -- Swap statusline: file path = normal fg, git branch = muted
      hl(0, 'MiniStatuslineFilename', { link = 'StatusLine' })
      hl(0, 'MiniStatuslineDevinfo',  { link = 'StatusLineNC' })
    end,
  },

  -- Additional colorschemes from vimrc
  { 'tomasiser/vim-code-dark', lazy = true },
  { 'rhysd/vim-color-spring-night', lazy = true },
  { 'nordtheme/vim', name = 'nord', lazy = true },
  { 'w0ng/vim-hybrid', lazy = true },

  -- session management
  {
    "rmagatti/auto-session",
    enabled = false,
    lazy = false,

    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
        allowed_dirs = {"c:/ember_repos/*", "~/Repos/*"},
        -- suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
      -- log_level = 'debug',
      pre_save_cmds = {
        function()
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.bo[buf].buftype == 'terminal' then
              vim.api.nvim_buf_delete(buf, { force = true })
            end
          end
        end,
      },
    },
  },
  -- window management
  { "szw/vim-maximizer" }
}

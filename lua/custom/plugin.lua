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

  -- Netrw enhancement (- to open in directory of current file)
  'tpope/vim-vinegar',

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
      vim.g.floaterm_shell = 'pwsh'
      vim.g.floaterm_opener = 'edit'
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
    end,
  },

  -- Additional colorschemes from vimrc
  { 'tomasiser/vim-code-dark', lazy = true },
  { 'rhysd/vim-color-spring-night', lazy = true },
  { 'nordtheme/vim', name = 'nord', lazy = true },
  { 'w0ng/vim-hybrid', lazy = true },
}

-- lua/plugins/editor.lua
--
-- Motions, text manipulation and window management. Small plugins that change
-- how editing feels rather than what the editor shows.
--
-- Keymaps
--   s / S / r / R  flash jump, treesitter jump, remote, treesitter search
--   ga             easy-align (motion or visual)
--   cs ds ys       vim-surround
--   <C-w>m         maximize the current window
--   <C-a> <C-e>    readline motions in insert and command mode (vim-rsi)
--
-- Buffers are tab-local here (scope.nvim), so :bnext and the buffer pickers
-- stay inside the current tab.

---@module 'lazy'
---@type LazySpec
return {
  -- Jump anywhere on screen. Owns s/S/r/R — never map those in
  -- config/keymaps.lua, which loads later and would silently win.
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    ---@type Flash.Config
    opts = {},
    keys = {
      {
        's',
        mode = { 'n', 'x', 'o' },
        -- Anchor the search at a word boundary so `sfo` targets the start of
        -- "foo" rather than any embedded match.
        function() require('flash').jump { search = { mode = function(str) return '\\<' .. str end } } end,
        desc = 'Flash',
      },
      { 'S', mode = { 'n', 'x', 'o' }, function() require('flash').treesitter() end, desc = 'Flash Treesitter' },
      { 'r', mode = 'o', function() require('flash').remote() end, desc = 'Remote Flash' },
      { 'R', mode = { 'o', 'x' }, function() require('flash').treesitter_search() end, desc = 'Treesitter Search' },
      { '<c-s>', mode = { 'c' }, function() require('flash').toggle() end, desc = 'Toggle Flash Search' },
    },
  },

  -- cs"' / ds" / ysiw)
  'tpope/vim-surround',

  -- Makes plugin mappings repeatable with `.`
  'tpope/vim-repeat',

  -- Readline bindings (C-a, C-e, C-d) in insert and command mode
  'tpope/vim-rsi',

  -- Zoom one split to fill the tab, and back. <F3> is the plugin's own
  -- default; listed here so lazy-loading does not quietly drop it.
  {
    'szw/vim-maximizer',
    cmd = 'MaximizerToggle',
    keys = {
      { '<C-w>m', '<cmd>MaximizerToggle<cr>', desc = 'Maximize window' },
      { '<C-w>m', '<cmd>MaximizerToggle<cr>gv', mode = 'v', desc = 'Maximize window' },
      { '<F3>', '<cmd>MaximizerToggle<cr>', desc = 'Maximize window' },
      { '<F3>', '<cmd>MaximizerToggle<cr>gv', mode = 'v', desc = 'Maximize window' },
      { '<F3>', '<C-o><cmd>MaximizerToggle<cr>', mode = 'i', desc = 'Maximize window' },
    },
  },

  -- ga<motion> or ga in visual mode to align on a delimiter
  {
    'junegunn/vim-easy-align',
    keys = {
      { 'ga', '<Plug>(EasyAlign)', mode = { 'n', 'x' }, desc = 'Easy Align' },
    },
  },

  { 'windwp/nvim-autopairs', event = 'InsertEnter', opts = {} },

  -- Match the file's existing indentation instead of forcing the settings.lua
  -- default onto someone else's code.
  { 'NMAC427/guess-indent.nvim', opts = {} },

  -- Tab-local buffers. Neovim's buffer list is global, so scope.nvim unlists
  -- the buffers that belong to other tabs: a new tab starts empty, and :bnext,
  -- <leader>fb and :ls only see the current tab's buffers. `:ScopeMoveBuf {nr}`
  -- hands a buffer to another tab. Not lazy — it has to see every tab and
  -- buffer from startup to keep its bookkeeping straight.
  { 'tiagovla/scope.nvim', lazy = false, opts = {} },

  -- Chdir to the project root, so pickers and :grep stay scoped
  'airblade/vim-rooter',

  -- "3/10" match count in the command line while searching
  'google/vim-searchindex',
}

-- lua/plugins/terminal.lua
--
-- Floating and split terminals. The shell and the window sizes come from
-- config/settings.lua.
--
-- Keymaps
--   <C-/>       toggle the floaterm      <C-q>  kill it
--   <leader>uf  new floating terminal    <leader>ub / <leader>ur  split below / right
--   <leader>ul  last terminal            <leader>ui  first terminal
--   <C-R>       (visual) send selection to the terminal
--
-- Plain :term splits on <leader>bb and <leader>br live in config/keymaps.lua.

local s = require 'config.settings'

---@module 'lazy'
---@type LazySpec
return {
  {
    'voldikss/vim-floaterm',
    lazy = false,
    keys = {
      { '<C-/>', desc = 'Toggle floaterm' },
      { '<C-q>', desc = 'Kill floaterm' },
      { '<leader>uf', ('<cmd>FloatermNew --wintype=float --width=%s<cr>'):format(s.floaterm.float_width), desc = '[U]I: new floating term' },
      { '<leader>ub', '<cmd>FloatermNew --wintype=split<cr>', desc = '[U]I: new term below' },
      { '<leader>ur', '<cmd>FloatermNew --wintype=vsplit<cr>', desc = '[U]I: new term right' },
      { '<leader>ul', '<cmd>FloatermLast<cr>', desc = '[U]I: [L]ast term' },
      { '<leader>ui', '<cmd>FloatermFirst<cr>', desc = '[U]I: F[i]rst term' },
      { '<C-R>', ':FloatermSend<cr>', mode = 'v', silent = true, desc = 'Send selection to terminal' },
    },
    init = function()
      -- Toggle and kill are set as g: variables rather than keys above
      -- because floaterm creates them itself across every mode.
      vim.g.floaterm_keymap_toggle = '<C-/>'
      vim.g.floaterm_keymap_kill = '<C-q>'
      vim.g.floaterm_shell = s.shell
      vim.g.floaterm_opener = 'edit'
      vim.g.floaterm_wintype = 'vsplit'
      vim.g.floaterm_width = s.floaterm.width
    end,
  },
}

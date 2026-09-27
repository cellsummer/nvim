-- lua/plugins/terminal.lua
--
-- Floating and split terminals, and the multiplexer layer that lets Neovide
-- stand in for a terminal emulator. The shell, the window sizes and the
-- on/off switch for the multiplexer keys come from config/settings.lua.
--
-- Every terminal here is a floaterm rather than a plain :term, because
-- floaterm puts a `floaterm` command and a $GIT_EDITOR on the shell's PATH
-- that open files in this Neovim. `git commit` and `floaterm notes.md` do the
-- right thing on macOS and Windows alike, with no shell profile to maintain.
--
-- Keymaps
--   <M-CR>      new shell in its own tab    <M-q>  close the pane, or its tab
--   <M-Space>   shell pane below            <M-\>  shell pane right
--   <M-h/l>     previous / next tab
--   <C-/>       toggle the side terminal    <C-q>  kill it
--   <leader>uf  new floating terminal       <leader>ub / <leader>ur  below / right
--   <leader>un / <leader>up  next / previous terminal in the ring
--   <leader>ul  last terminal               <leader>ui  first terminal
--   <C-R>       (visual) send selection to the terminal
--
-- Plain :term splits on <leader>bb and <leader>br live in config/keymaps.lua.

local s = require 'config.settings'

-- A tab holding nothing but a shell is this config's equivalent of a
-- multiplexer window. :only is safe here because the tab is one command old
-- and holds only the empty buffer :tabnew just made.
local SHELL_TAB = '<cmd>tabnew<cr><cmd>FloatermNew --wintype=split --height=1.0<cr><cmd>only<cr>'

-- <M-q> reads as "close what I am looking at": the shell under the cursor, or
-- else the tab. FloatermKill takes the window with it, so a tab holding one
-- shell closes in a single press either way.
local function close_pane()
  if vim.bo.filetype == 'floaterm' then
    vim.cmd 'FloatermKill'
  else
    pcall(vim.cmd, 'tabclose')
  end
end

-- Chords for the multiplexer layer. <Cmd> mappings do not change mode, so one
-- mapping answers from a file buffer, from insert and from the shell itself.
-- <M-j> and <M-k> are absent on purpose: config/keymaps.lua moves lines with
-- them, and the readline chords the shell still needs are in that file too.
local mux = {
  { '<M-CR>', SHELL_TAB, 'Term: new tab' },
  { '<M-Space>', '<cmd>FloatermNew --wintype=split<cr>', 'Term: pane below' },
  { '<M-Bslash>', '<cmd>FloatermNew --wintype=vsplit<cr>', 'Term: pane right' },
  { '<M-h>', '<cmd>tabprevious<cr>', 'Term: previous tab' },
  { '<M-l>', '<cmd>tabnext<cr>', 'Term: next tab' },
  { '<M-q>', close_pane, 'Term: close pane or tab' },
}

local mux_keys = {}
if s.terminal_ui.enabled then
  for _, m in ipairs(mux) do
    table.insert(mux_keys, { m[1], m[2], mode = { 'n', 'i', 't' }, desc = m[3] })
  end
end

---@module 'lazy'
---@type LazySpec
return {
  {
    'voldikss/vim-floaterm',
    lazy = false,
    keys = vim.list_extend({
      { '<C-/>', desc = 'Toggle floaterm' },
      { '<C-q>', desc = 'Kill floaterm' },
      { '<leader>uf', ('<cmd>FloatermNew --wintype=float --width=%s<cr>'):format(s.floaterm.float_width), desc = '[U]I: new floating term' },
      { '<leader>ub', '<cmd>FloatermNew --wintype=split<cr>', desc = '[U]I: new term below' },
      { '<leader>ur', '<cmd>FloatermNew --wintype=vsplit<cr>', desc = '[U]I: new term right' },
      { '<leader>ul', '<cmd>FloatermLast<cr>', desc = '[U]I: [L]ast term' },
      { '<leader>ui', '<cmd>FloatermFirst<cr>', desc = '[U]I: F[i]rst term' },
      { '<leader>un', '<cmd>FloatermNext<cr>', desc = '[U]I: [N]ext term' },
      { '<leader>up', '<cmd>FloatermPrev<cr>', desc = '[U]I: [P]rev term' },
      { '<C-R>', ':FloatermSend<cr>', mode = 'v', silent = true, desc = 'Send selection to terminal' },
    }, mux_keys),
    init = function()
      -- Toggle and kill are set as g: variables rather than keys above
      -- because floaterm creates them itself across every mode.
      vim.g.floaterm_keymap_toggle = '<C-/>'
      vim.g.floaterm_keymap_kill = '<C-q>'
      vim.g.floaterm_shell = s.shell
      vim.g.floaterm_opener = 'edit'
      vim.g.floaterm_wintype = 'vsplit'
      vim.g.floaterm_width = s.floaterm.width

      -- Opening one shell must not hide the one beside it: panes in the same
      -- tab are meant to be visible together. floaterm hides same-position
      -- windows by default.
      vim.g.floaterm_autohide = 0
    end,
  },
}

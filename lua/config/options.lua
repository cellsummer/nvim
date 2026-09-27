-- lua/config/options.lua
--
-- All vim options, set once. Values that get adjusted often live in
-- `config.settings`; this file only applies them.

local s = require 'config.settings'

local o = vim.o
local opt = vim.opt

-- No Python plugins are used, so silence the python3 provider health warning
-- without installing pynvim.
vim.g.loaded_python3_provider = 0

vim.g.have_nerd_font = s.nerd_font

-- ============================================================
-- UI
-- ============================================================

o.number = true
o.relativenumber = true
o.cursorline = true
o.showmode = false -- mini.statusline already shows it
o.signcolumn = 'yes'
o.scrolloff = s.scrolloff
o.cmdheight = 1
o.equalalways = false -- keep manual split sizes when opening windows
o.splitright = true
o.splitbelow = true
o.confirm = true -- prompt instead of failing on :q with unsaved changes

o.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

o.showmatch = true
o.matchtime = 2
o.errorbells = false
o.visualbell = false
o.lazyredraw = false

-- ============================================================
-- Editing
-- ============================================================

o.mouse = 'a'
o.hidden = true
o.history = 5000
o.autoread = true
o.backspace = 'eol,start,indent'
opt.whichwrap:append '<,>,h,l' -- let h/l wrap across lines
opt.iskeyword:remove '-' -- treat foo-bar as two words

o.expandtab = s.indent.expandtab
o.tabstop = s.indent.width
o.softtabstop = s.indent.width
o.shiftwidth = s.indent.width
o.smarttab = true
o.autoindent = true
o.smartindent = true
o.breakindent = true

o.wrap = true
o.linebreak = true
o.textwidth = s.textwidth

o.foldcolumn = '0'
o.foldmethod = 'indent'
o.foldlevel = 99

-- coc.nvim drives its CursorHold highlighting off this; 300ms is its minimum
-- recommended value.
o.updatetime = 300
o.timeoutlen = 500

-- Sync clipboard with the OS. Scheduled because it can slow startup.
vim.schedule(function() o.clipboard = 'unnamedplus' end)

-- ============================================================
-- Search
-- ============================================================

o.ignorecase = true
o.smartcase = true
o.inccommand = 'split' -- live preview of :s
o.magic = s.magic_search
o.regexpengine = 0 -- auto-select NFA or backtracking

if vim.fn.executable 'rg' == 1 then o.grepprg = 'rg --vimgrep --no-heading --smart-case' end

-- ============================================================
-- Files
-- ============================================================

o.encoding = 'utf8'
o.fileformats = s.fileformats
o.undofile = true
o.backup = false
o.writebackup = false
o.swapfile = false

o.wildmenu = true
opt.wildignore:append '*.o,*~,*.pyc'
if s.os.win then
  opt.wildignore:append '.git\\*,.hg\\*,.svn\\*'
else
  opt.wildignore:append '*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store'
end

-- ============================================================
-- Terminal
-- ============================================================

-- The 10000-line default is thin for a shell you use all day. This is the
-- maximum 'scrollback' accepts.
o.scrollback = 100000

-- Lets the window a shell tab holds for opening files shrink to nothing. See
-- settings.terminal_ui.full_shell for why that window has to exist at all.
o.winminwidth = 0

-- ============================================================
-- Diagnostics
-- ============================================================

vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },
  virtual_text = true,
  virtual_lines = false,

  -- Open the float on [d / ]d so the message is readable where you land.
  jump = { on_jump = function() vim.diagnostic.open_float() end },
}

-- ============================================================
-- Filetype tweaks
-- ============================================================

vim.g.pyindent_open_paren = 0
vim.g.markdown_folding = 1
vim.g.markdown_fenced_languages = { 'html', 'python', 'sh', 'sql', 'powershell=sh' }

-- ============================================================
-- Neovide
-- ============================================================

-- The font lives in Neovide's own config.toml, not here:
-- ~/.config/neovide/config.toml on macOS,
-- ~/AppData/Roaming/neovide/config.toml on Windows.
if vim.g.neovide then
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_remember_window_size = true
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_cursor_trail_size = 0

  -- With a shell in the window, closing it kills a running job. Ask first.
  vim.g.neovide_confirm_quit = true

  -- macOS treats Option as a dead key for accented characters, so no <M-...>
  -- chord reaches Neovim until Neovide claims it. Take the left key only and
  -- leave the right one able to type é.
  if s.os.mac then vim.g.neovide_input_macos_option_key_is_meta = 'only_left' end

  local function scale(by)
    return function() vim.g.neovide_scale_factor = by and vim.g.neovide_scale_factor + by or 1 end
  end

  -- Zoom has to answer from a shell too, not only from a file buffer.
  local zoom_modes = { 'n', 'i', 't' }
  vim.keymap.set(zoom_modes, '<C-=>', scale(0.1), { silent = true, desc = 'Neovide: zoom in' })
  vim.keymap.set(zoom_modes, '<C-->', scale(-0.1), { silent = true, desc = 'Neovide: zoom out' })
  vim.keymap.set(zoom_modes, '<C-0>', scale(nil), { silent = true, desc = 'Neovide: reset zoom' })
end

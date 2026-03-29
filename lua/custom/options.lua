-- lua/custom/options.lua
-- Migrated from _vimrc Options section.
-- Options already set by kickstart's init.lua are omitted:
--   number, mouse, showmode, clipboard, breakindent, undofile,
--   ignorecase, smartcase, signcolumn, splitright, splitbelow,
--   list/listchars, inccommand, cursorline, confirm

local o = vim.o
local opt = vim.opt

-- History
o.history = 5000

-- No shell slash conversion (Windows)
o.shellslash = false

-- Relative line numbers
o.relativenumber = true

-- Keep more context around cursor (vimrc used 20; init.lua defaults to 10)
o.scrolloff = 20

-- Faster CursorHold (needed by coc.nvim); init.lua sets 250 but coc wants 300
o.updatetime = 300

-- Sequence timeout (vimrc used 500; init.lua sets 300)
o.timeoutlen = 500

-- Command bar
o.cmdheight = 1

-- Allow switching buffers without saving
o.hidden = true

-- Backspace behaviour
o.backspace = 'eol,start,indent'

-- Allow h/l/<Left>/<Right> to wrap across lines
opt.whichwrap:append '<,>,h,l'

-- Don't redraw during macros
o.lazyredraw = false

-- Disable magic regex mode (use \m explicitly when needed)
o.magic = false

-- Show matching bracket
o.showmatch = true
o.matchtime = 2

-- No bells
o.errorbells = false
o.visualbell = false

-- Remove '-' from keyword characters
opt.iskeyword:remove '-'

-- Don't auto-resize splits
o.equalalways = false

-- Indentation: spaces, width 4
o.expandtab   = true
o.tabstop     = 4
o.softtabstop = 4
o.shiftwidth  = 4
o.smarttab    = true
o.autoindent  = true
o.smartindent = true

-- Folding
o.foldcolumn = '0'
o.foldmethod = 'indent'

-- Line wrap
o.wrap       = true
o.linebreak  = true
o.textwidth  = 500

-- Auto-reload files changed outside nvim
o.autoread = true

-- Regex engine (0 = auto-select)
o.regexpengine = 0

-- File encoding / format
o.encoding    = 'utf8'
o.fileformats = 'dos'

-- No backup / swap files
o.backup      = false
o.writebackup = false
o.swapfile    = false

-- Grep: use git grep by default (fast, respects .gitignore)
if vim.fn.executable 'rg' == 1 then
  o.grepprg = 'git grep -n'
end

-- Wildmenu
o.wildmenu = true
opt.wildignore:append '*.o,*~,*.pyc'
if vim.fn.has 'win32' == 1 then
  opt.wildignore:append '.git\\*,.hg\\*,.svn\\*'
else
  opt.wildignore:append '*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store'
end

-- Neovide
if vim.g.neovide then
  -- Font (from vimrc: Maple_Mono_NF_Medium h10 W500)
  -- Commented alternatives from vimrc kept for reference:
  -- vim.o.guifont = 'Cascadia_Code:h10'
  -- vim.o.guifont = 'Fira_Code_Retina:h10'
  -- vim.o.guifont = 'Berkeley_Mono_Medium_Condensed:h11:b'
  vim.o.guifont = 'Maple Mono NF:h10:W500'

  -- No UI chrome (equivalent to guioptions=)
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_remember_window_size   = true

  -- Cursor
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_cursor_trail_size       = 0
end

-- Python indent
vim.g.pyindent_open_paren = 0

-- Markdown
vim.g.markdown_folding = 1
vim.g.markdown_fenced_languages = { 'html', 'python', 'sh', 'sql', 'powershell=sh' }

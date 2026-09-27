-- lua/config/keymaps.lua
--
-- Editor keymaps that do not belong to any plugin. A plugin's keymaps live in
-- its own file under lua/plugins/ so the spec and its bindings stay together.
--
-- Two rules, both learned the hard way:
--   1. Keep every leader binding a leaf. `<leader>a` must not exist if
--      `<leader>ac` does — mini.clue ignores 'timeoutlen'. Group prefixes are
--      declared in config.settings.leader_groups.
--   2. This file loads after lazy.setup, so anything set here silently wins
--      over a plugin's lazy-load key stub. Do not map keys a plugin owns
--      (`s`/`S`/`r`/`R` belong to flash.nvim).
--
-- Press <leader> to browse bindings, or <leader>sk to search them all.

local s = require 'config.settings'
local map = vim.keymap.set

-- ============================================================
-- Core
-- ============================================================

map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

-- Neovim 0.13 moved multicursor-clear onto <C-l>, which we reclaim below for
-- window focus. <BS> clears both search highlight and multicursor marks.
map('n', '<BS>', function()
  vim.cmd.nohlsearch()
  vim.api.nvim_buf_clear_namespace(0, vim.api.nvim_create_namespace 'nvim.multicursor', 0, -1)
end, { silent = true, desc = 'Clear search highlight + multicursors' })

map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Open URL under cursor. On Windows `vim.ui.open` shells out to explorer.exe
-- and can hang for seconds; `start` via cmd returns immediately.
map('n', 'gx', function()
  local url = vim.fn.expand '<cfile>'
  if s.os.win then
    vim.fn.jobstart({ 'cmd', '/c', 'start', '', url }, { detach = true })
  else
    vim.ui.open(url)
  end
end, { desc = 'Open URL under cursor' })

map('n', '<F2>', ':%s/<C-r><C-w>//gc<Left><Left><Left>', { desc = 'Replace word under cursor' })
map('n', '<leader>cd', '<cmd>cd %:p:h<cr><cmd>pwd<cr>', { desc = '[C]hange [D]ir to file' })
map('n', '<leader>us', '<cmd>setlocal spell!<cr>', { desc = 'Toggle [U]se [S]pell' })

-- Strip Windows ^M when a file arrives with mixed line endings.
map('n', '<leader>mm', "mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm", { desc = '[M]isc: re[m]ove ^M' })

-- Swap path separators on the current line, preserving the search register.
map('n', '<Bslash>/', ':let tmp=@/<BAR>s:\\:/:ge<BAR>let @/=tmp<BAR>noh<CR>', { desc = 'Backslash to slash' })
map('n', '<Bslash><Bslash>', ':let tmp=@/<BAR>s:/:\\:ge<BAR>let @/=tmp<BAR>noh<CR>', { desc = 'Slash to backslash' })

-- Paste from Excel: a tab-separated row becomes one value per line.
map({ 'n', 'v' }, '<leader>pt', 'P<cmd>s/\\t/\\r/g<cr>', { silent = true, desc = '[P]aste and [T]ranspose' })

map('n', 'gp', '`[v`]', { silent = true, desc = 'Select pasted text' })

-- ============================================================
-- Windows
-- ============================================================

map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

map('n', '<C-Up>', '<cmd>resize -5<CR>', { desc = 'Shrink window height' })
map('n', '<C-Down>', '<cmd>resize +5<CR>', { desc = 'Grow window height' })
map('n', '<C-Left>', '<cmd>vertical resize -5<CR>', { desc = 'Shrink window width' })
map('n', '<C-Right>', '<cmd>vertical resize +5<CR>', { desc = 'Grow window width' })

-- ============================================================
-- Buffers and tabs
-- ============================================================

-- :Bclose from _vimrc — drop the current buffer without closing its window.
local function buf_close()
  -- Terminals are the main event now that Neovide stands in for a terminal
  -- emulator, and `x` is one finger slip away from killing a running shell.
  if vim.bo.buftype == 'terminal' then
    vim.notify('Close a terminal with <M-q>', vim.log.levels.WARN)
    return
  end

  local cur = vim.fn.bufnr '%'
  local alt = vim.fn.bufnr '#'
  if vim.fn.buflisted(alt) == 1 then
    vim.cmd 'buffer #'
  else
    vim.cmd 'bnext'
  end
  if vim.fn.bufnr '%' == cur then vim.cmd 'new' end
  if vim.fn.buflisted(cur) == 1 then vim.cmd('bdelete! ' .. cur) end
end

local function buf_close_and_tab()
  buf_close()
  pcall(vim.cmd, 'tabclose')
end

map('n', 'x', buf_close, { desc = 'Close buffer' })
map('n', '<leader>bd', buf_close_and_tab, { desc = '[B]uffer [D]elete' })
map('n', '<leader>bk', buf_close_and_tab, { desc = '[B]uffer [K]ill' })
map('n', '<leader>ba', '<cmd>bufdo bd<cr>', { desc = '[B]uffer delete [A]ll' })
map('n', '<leader>bn', '<cmd>bnext<cr>', { desc = '[B]uffer [N]ext' })
map('n', '<leader>bp', '<cmd>bprevious<cr>', { desc = '[B]uffer [P]rev' })
map('n', '<S-l>', '<cmd>bnext<cr>', { desc = 'Next buffer' })
map('n', '<S-h>', '<cmd>bprevious<cr>', { desc = 'Prev buffer' })

-- q closes a readonly buffer (help, fugitive, quickfix); elsewhere it records
-- a macro as usual.
map('n', 'q', function() return vim.bo.readonly and '<cmd>close!<CR>' or 'q' end, { expr = true, desc = 'Close readonly buffer / record macro' })

map('n', '<leader>tt', '<cmd>tabnew<CR>', { desc = '[T]ab New' })
map('n', '<leader>tk', '<cmd>tabclose<CR>', { desc = '[T]ab [K]ill' })
map('n', '<leader>tn', '<cmd>tabnext<CR>', { desc = '[T]ab [N]ext' })
map('n', '<leader>tp', '<cmd>tabprevious<CR>', { desc = '[T]ab [P]rev' })
map('n', '<leader>tl', function() vim.cmd('tabn ' .. vim.g.lasttab) end, { desc = '[T]ab [L]ast' })
map('n', '<leader>te', function()
  local dir = vim.fn.escape(vim.fn.expand '%:p:h', ' ')
  vim.cmd('tabedit ' .. dir .. '/')
end, { desc = '[T]ab [E]dit in file dir' })

-- ============================================================
-- Moving text
-- ============================================================

map('n', '<M-j>', 'mz:m+<cr>`z', { desc = 'Move line down' })
map('n', '<M-k>', 'mz:m-2<cr>`z', { desc = 'Move line up' })
map('v', '<M-j>', ":m'>+<cr>`<my`>mzgv`yo`z", { desc = 'Move selection down' })
map('v', '<M-k>', ":m'<-2<cr>`>my`<mzgv`yo`z", { desc = 'Move selection up' })

-- Wrap the selection in a bracket or quote pair.
for _, pair in ipairs { { ')', '(', ')' }, { ']', '[', ']' }, { '}', '{', '}' }, { '"', '"', '"' }, { "'", "'", "'" }, { '`', '`', '`' } } do
  local key, open, close = pair[1], pair[2], pair[3]
  map('v', '$' .. key, string.format('<esc>`>a%s<esc>`<i%s<esc>', close, open), { desc = 'Surround selection with ' .. open .. close })
end

-- ============================================================
-- Search
-- ============================================================

-- * and # in visual mode search for the selection rather than the word under
-- the cursor.
local function visual_search(direction)
  vim.cmd 'normal! "vy'
  local pattern = vim.fn.escape(vim.fn.getreg 'v', '\\/.*\'$^~[]'):gsub('\n$', '')
  vim.fn.setreg('/', pattern)
  vim.api.nvim_feedkeys(direction .. pattern .. '\13', 'n', false)
end

map('v', '*', function() visual_search '/' end, { silent = true, desc = 'Search selection forward' })
map('v', '#', function() visual_search '?' end, { silent = true, desc = 'Search selection backward' })

-- ============================================================
-- Insert and command mode
-- ============================================================

map('i', 'jk', '<ESC>', { desc = 'Exit insert mode' })
map('i', '<C-;>', '<ESC>', { desc = 'Exit insert mode' })

map('c', '<C-A>', '<Home>', { desc = 'Beginning of line' })
map('c', '<C-E>', '<End>', { desc = 'End of line' })
map('c', '<C-K>', '<C-U>', { desc = 'Delete to line start' })
map('c', '<C-P>', '<Up>', { desc = 'Previous command' })
map('c', '<C-N>', '<Down>', { desc = 'Next command' })

-- ============================================================
-- Terminal
-- ============================================================

map('n', '<leader>bb', ('<cmd>sp term://%s<cr>'):format(s.shell), { desc = '[B]uffer: term [B]elow' })
map('n', '<leader>br', ('<cmd>vs term://%s<cr>'):format(s.shell), { desc = '[B]uffer: term [R]ight' })

-- Leaving terminal mode brings the line numbers back, so scrollback reads like
-- a file. That belongs to TermLeave in config/autocmds.lua rather than to these
-- keys, so typing <C-\><C-n> by hand gets the same result.
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
map('t', '<C-;>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
map('t', '<C-h>', '<C-\\><C-n><C-w>h', { silent = true, desc = 'Terminal: focus left' })
map('t', '<C-j>', '<C-\\><C-n><C-w>j', { silent = true, desc = 'Terminal: focus down' })
map('t', '<C-k>', '<C-\\><C-n><C-w>k', { silent = true, desc = 'Terminal: focus up' })

-- Neovim swallows these before the shell sees them (<C-w> is the window
-- prefix, <C-u> scrolls), so write the raw control byte to the job directly
-- and let the shell's own readline handle it.
local function term_send(char)
  return function()
    local job = vim.b.terminal_job_id
    if job then vim.api.nvim_chan_send(job, char) end
  end
end

map('t', '<C-w>', term_send '\x17', { desc = 'Terminal: delete word' })
map('t', '<C-u>', term_send '\x15', { desc = 'Terminal: delete to line start' })
map('t', '<C-a>', term_send '\x01', { desc = 'Terminal: beginning of line' })
map('t', '<C-e>', term_send '\x05', { desc = 'Terminal: end of line' })

-- Readline's <C-k> (delete to line end) is deliberately absent: the window
-- focus binding above claims it. Use <C-e> then <C-u> if you need it.

-- Neovide has to claim Option as Meta before any <M-...> chord arrives, which
-- takes these away from the shell's own line editor. Hand them back the same
-- way. The arrows stay on word motion so muscle memory survives, leaving
-- <M-h> and <M-l> free for the tab chords in plugins/terminal.lua.
if s.terminal_ui.readline_keys then
  map('t', '<M-b>', term_send '\x1bb', { desc = 'Terminal: back one word' })
  map('t', '<M-Left>', term_send '\x1bb', { desc = 'Terminal: back one word' })
  map('t', '<M-f>', term_send '\x1bf', { desc = 'Terminal: forward one word' })
  map('t', '<M-Right>', term_send '\x1bf', { desc = 'Terminal: forward one word' })
  map('t', '<M-d>', term_send '\x1bd', { desc = 'Terminal: delete word forward' })
  map('t', '<M-BS>', term_send '\x1b\x7f', { desc = 'Terminal: delete word back' })
  map('t', '<M-.>', term_send '\x1b.', { desc = 'Terminal: insert last argument' })
end

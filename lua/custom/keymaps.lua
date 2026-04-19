-- lua/custom/keymaps.lua
-- Migrated from _vimrc Mappings section
-- Note: <C-h/j/k/l> window nav and <Esc><Esc> terminal exit are already set in init.lua

local map = vim.keymap.set

-- Buffer close helper (equivalent to :Bclose in vimrc)
local function buf_close()
  local cur = vim.fn.bufnr '%'
  local alt = vim.fn.bufnr '#'
  if vim.fn.buflisted(alt) == 1 then
    vim.cmd 'buffer #'
  else
    vim.cmd 'bnext'
  end
  if vim.fn.bufnr '%' == cur then
    vim.cmd 'new'
  end
  if vim.fn.buflisted(cur) == 1 then
    vim.cmd('bdelete! ' .. cur)
  end
end

-- x closes buffer (replaces default delete-char); s disabled
map('n', 'x', buf_close, { desc = 'Close buffer' })
map('n', 's', '<Nop>')

-- Clear search highlight (supplement to <Esc> in init.lua)
map('n', '<BS>', '<cmd>noh<cr>', { silent = true })

-- Window resize
map('n', '<C-Up>', '<cmd>resize -5<CR>')
map('n', '<C-Down>', '<cmd>resize +5<CR>')
map('n', '<C-Left>', '<cmd>vertical resize -5<CR>')
map('n', '<C-Right>', '<cmd>vertical resize +5<CR>')

-- Close readonly buffers with q; otherwise normal q (macro)
map('n', 'q', function()
  if vim.bo.readonly then
    return '<cmd>close!<CR>'
  else
    return 'q'
  end
end, { expr = true })

-- Remove Windows ^M when encoding gets messed up
map('n', '<Leader>m', "mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm")

-- Quick scribble buffer
map('n', '<leader>n', '<cmd>e ~/buffer<cr>')

-- Toggle spell check
map('n', '<leader>us', '<cmd>setlocal spell!<cr>', { desc = 'Toggle [U]se [S]pell' })

-- Toggle paste mode
map('n', '<leader>pp', '<cmd>setlocal paste!<cr>', { desc = 'Toggle [P]aste mode' })

-- Move lines up/down with Alt+j/k
map('n', '<M-j>', 'mz:m+<cr>`z')
map('n', '<M-k>', 'mz:m-2<cr>`z')
map('v', '<M-j>', ":m'>+<cr>`<my`>mzgv`yo`z")
map('v', '<M-k>', ":m'<-2<cr>`>my`<mzgv`yo`z")

-- Terminal mode
-- Exit terminal
map('t', '<C-;>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
-- Note: <Esc><Esc> to exit terminal is already set in init.lua

-- Readline keys for pwsh: send raw control characters to the shell process
-- Neovim intercepts <C-w> (window prefix) so we bypass it via the channel
local function term_send(char)
  return function()
    local job_id = vim.b.terminal_job_id
    if job_id then vim.api.nvim_chan_send(job_id, char) end
  end
end
map('t', '<C-w>', term_send '\x17', { desc = 'Terminal: delete word (readline)' })  -- backward-kill-word
map('t', '<C-u>', term_send '\x15', { desc = 'Terminal: delete to line start (readline)' })
map('t', '<C-k>', term_send '\x0b', { desc = 'Terminal: delete to line end (readline)' })
map('t', '<C-a>', term_send '\x01', { desc = 'Terminal: beginning of line (readline)' })
map('t', '<C-e>', term_send '\x05', { desc = 'Terminal: end of line (readline)' })

-- Visual mode: search for current selection with * and #
local function visual_search(forward)
  vim.cmd 'normal! "vy'
  local raw = vim.fn.getreg 'v'
  local pattern = vim.fn.escape(raw, '\\/.*\'$^~[]')
  pattern = pattern:gsub('\n$', '')
  vim.fn.setreg('/', pattern)
  local key = forward and '/' or '?'
  vim.api.nvim_feedkeys(key .. pattern .. '\13', 'n', false)
end
map('v', '*', function() visual_search(true) end, { silent = true })
map('v', '#', function() visual_search(false) end, { silent = true })

-- Visual mode: wrap selection in brackets/quotes
map('v', '$)', '<esc>`>a)<esc>`<i(<esc>')
map('v', '$]', '<esc>`>a]<esc>`<i[<esc>')
map('v', '$}', '<esc>`>a}<esc>`<i{<esc>')
map('v', '$"', '<esc>`>a"<esc>`<i"<esc>')
map('v', "$'", "<esc>`>a'<esc>`<i'<esc>")
map('v', '$`', '<esc>`>a`<esc>`<i`<esc>')

-- Command mode readline bindings
map('c', '<C-A>', '<Home>')
map('c', '<C-E>', '<End>')
map('c', '<C-K>', '<C-U>')
map('c', '<C-P>', '<Up>')
map('c', '<C-N>', '<Down>')

-- Tabs
map('n', '<leader>tk', '<cmd>tabclose<CR>', { desc = '[T]ab [K]ill' })
map('n', '<leader>tn', '<cmd>tabnext<CR>', { desc = '[T]ab [N]ext' })
map('n', '<leader>tp', '<cmd>tabprevious<CR>', { desc = '[T]ab [P]rev' })
map('n', '<leader>te', function()
  local dir = vim.fn.escape(vim.fn.expand '%:p:h', ' ')
  vim.cmd('tabedit ' .. dir .. '/')
end, { desc = '[T]ab [E]dit in file dir' })

-- Toggle between last two tabs
vim.g.lasttab = 1
vim.api.nvim_create_autocmd('TabLeave', {
  callback = function() vim.g.lasttab = vim.fn.tabpagenr() end,
})
map('n', '<leader>tl', function() vim.cmd('tabn ' .. vim.g.lasttab) end, { desc = '[T]ab [L]ast' })

-- Buffers
map('n', '<leader>bd', function()
  buf_close()
  pcall(vim.cmd, 'tabclose')
end, { desc = '[B]uffer [D]elete' })
map('n', '<leader>bk', function()
  buf_close()
  pcall(vim.cmd, 'tabclose')
end, { desc = '[B]uffer [K]ill' })
map('n', '<leader>ba', '<cmd>bufdo bd<cr>', { desc = '[B]uffer delete [A]ll' })
map('n', '<S-l>', '<cmd>bnext<cr>', { desc = 'Next buffer' })
map('n', '<S-h>', '<cmd>bprevious<cr>', { desc = 'Prev buffer' })
map('n', '<leader>bn', '<cmd>bnext<cr>', { desc = '[B]uffer [N]ext' })
map('n', '<leader>bp', '<cmd>bprevious<cr>', { desc = '[B]uffer [P]rev' })

-- Replace word under cursor (interactive)
map('n', '<F2>', ':%s/<C-r><C-w>//gc<Left><Left><Left>', { desc = 'Replace word under cursor' })

-- File explorer (netrw)
map('n', '<leader>e', '<cmd>Lex<cr>', { desc = 'Open [E]xplorer (left)' })
map('n', '<leader>ee', '<cmd>Vex<cr>', { desc = 'Open [E]xplorer (vertical)' })

-- CD to current file's directory
map('n', '<leader>cd', '<cmd>cd %:p:h<cr><cmd>pwd<cr>', { desc = '[C]hange [D]ir to file' })

-- Picker keymaps (Snacks picker — migrated from Telescope/FZF)
map('n', '<leader><leader>', function() Snacks.picker.files() end, { desc = 'Find Files' })
map('n', '<C-p>', function() Snacks.picker.buffers() end, { desc = 'Find Buffers' })
map('n', '<leader>ff', function() Snacks.picker.git_files() end, { desc = '[F]ind Git [F]iles' })
map('n', '<leader>fg', function() Snacks.picker.git_status() end, { desc = '[F]ind [G]it Status' })
map('n', '<leader>fb', function() Snacks.picker.buffers() end, { desc = '[F]ind [B]uffers' })
map('n', '<leader>fj', function() Snacks.picker.jumps() end, { desc = '[F]ind [J]umplist' })
map('n', '<leader>f;', function() Snacks.picker.command_history() end, { desc = '[F]ind Command History' })
map('n', '<leader>fw', function() Snacks.picker.grep() end, { desc = '[F]ind by grep [W]ord' })
map('n', '<leader>ft', function() Snacks.picker.colorschemes() end, { desc = '[F]ind [T]heme/Colorscheme' })
map('n', '<leader>so', function() Snacks.picker.recent() end, { desc = '[S]earch [O]ld/Recent Files' })

-- Insert mode
map('i', 'jk', '<ESC>')
map('i', '<C-;>', '<ESC>')

-- ============================================================
-- coc.nvim
-- ============================================================


local function check_backspace()
  local col = vim.fn.col('.') - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

-- <C-n>: next completion item, or trigger refresh; <C-p>: previous
map('i', '<C-n>', function()
  if vim.fn['coc#pum#visible']() == 1 then
    return vim.fn['coc#pum#next'](1)
  elseif check_backspace() then
    return '\t'
  else
    return vim.fn['coc#refresh']()
  end
end, { silent = true, expr = true })

map('i', '<C-p>', function()
  if vim.fn['coc#pum#visible']() == 1 then
    return vim.fn['coc#pum#prev'](1)
  else
    return '<C-h>'
  end
end, { silent = true, expr = true })

-- <CR>: accept completion and trigger coc formatting
map('i', '<CR>', function()
  if vim.fn['coc#pum#visible']() == 1 then
    return vim.fn['coc#pum#confirm']()
  else
    return '<C-g>u<CR><c-r>=coc#on_enter()<CR>'
  end
end, { silent = true, expr = true })

-- <Tab>: confirm if pum is visible, otherwise insert tab
map('i', '<Tab>', function()
  if vim.fn.pumvisible() == 1 then
    return vim.fn['coc#pum#confirm']()
  else
    return '<C-g>u<Tab>'
  end
end, { silent = true, expr = true })

-- <C-Space>: trigger completion
map('i', '<C-Space>', 'coc#refresh()', { silent = true, expr = true })

-- [g / ]g: navigate diagnostics
map('n', '[g', '<Plug>(coc-diagnostic-prev)', { silent = true, nowait = true })
map('n', ']g', '<Plug>(coc-diagnostic-next)', { silent = true, nowait = true })

-- GoTo navigation
map('n', 'gd', '<Plug>(coc-definition)',      { silent = true, nowait = true })
map('n', 'gy', '<Plug>(coc-type-definition)', { silent = true, nowait = true })
map('n', 'gr', '<Plug>(coc-references)',      { silent = true, nowait = true })

-- K: show documentation in preview window
local function show_documentation()
  if vim.fn.CocAction('hasProvider', 'hover') then
    vim.fn.CocActionAsync('doHover')
  else
    vim.api.nvim_feedkeys('K', 'in', false)
  end
end
map('n', 'K', show_documentation, { silent = true })

-- Highlight symbol and references on CursorHold
vim.api.nvim_create_autocmd('CursorHold', {
  callback = function() vim.fn.CocActionAsync('highlight') end,
})

-- Symbol renaming
map('n', '<leader>lr', '<Plug>(coc-rename)', { desc = 'LSP [R]ename' })

-- Format selected
map({ 'n', 'x' }, '<leader>lf', '<Plug>(coc-format-selected)', { desc = 'LSP [F]ormat selected' })

-- Code actions
map({ 'n', 'x' }, '<leader>a',  '<Plug>(coc-codeaction-selected)', { desc = 'Code [A]ction (selection)' })
map('n',           '<leader>ac', '<Plug>(coc-codeaction-cursor)',   { desc = 'Code [A]ction at [C]ursor' })
map('n',           '<leader>as', '<Plug>(coc-codeaction-source)',   { desc = 'Code [A]ction [S]ource' })
map('n',           '<leader>qf', '<Plug>(coc-fix-current)',         { desc = '[Q]uick[F]ix current line' })

-- Refactor
map('n',           '<leader>re', '<Plug>(coc-codeaction-refactor)',          { silent = true, desc = '[Re]factor' })
map({ 'n', 'x' }, '<leader>r',  '<Plug>(coc-codeaction-refactor-selected)', { silent = true, desc = '[R]efactor selection' })

-- Code lens
map('n', '<leader>cl', '<Plug>(coc-codelens-action)', { desc = '[C]ode [L]ens' })

-- Text objects: function (if/af) and class (ic/ac)
map({ 'x', 'o' }, 'if', '<Plug>(coc-funcobj-i)')
map({ 'x', 'o' }, 'af', '<Plug>(coc-funcobj-a)')
map({ 'x', 'o' }, 'ic', '<Plug>(coc-classobj-i)')
map({ 'x', 'o' }, 'ac', '<Plug>(coc-classobj-a)')

-- Scroll float windows with <C-f> / <C-b>
map({ 'n', 'i', 'v' }, '<C-f>', function()
  if vim.fn['coc#float#has_scroll']() == 1 then
    return vim.fn['coc#float#scroll'](1)
  else
    return '<C-f>'
  end
end, { silent = true, nowait = true, expr = true })

map({ 'n', 'i', 'v' }, '<C-b>', function()
  if vim.fn['coc#float#has_scroll']() == 1 then
    return vim.fn['coc#float#scroll'](0)
  else
    return '<C-b>'
  end
end, { silent = true, nowait = true, expr = true })

-- <C-s>: selection ranges
map({ 'n', 'x' }, '<C-s>', '<Plug>(coc-range-select)', { silent = true })

-- User commands
vim.api.nvim_create_user_command('Format', function() vim.fn.CocActionAsync('format') end, { nargs = 0 })
vim.api.nvim_create_user_command('Fold',   function(o) vim.fn.CocAction('fold', o.fargs[1]) end, { nargs = '?' })
vim.api.nvim_create_user_command('OR',     function() vim.fn.CocActionAsync('runCommand', 'editor.action.organizeImport') end, { nargs = 0 })

-- CocList shortcuts
map('n', '<space>ca', ':<C-u>CocList diagnostics<cr>',  { silent = true, nowait = true, desc = 'Coc: [A]ll diagnostics' })
map('n', '<space>ce', ':<C-u>CocList extensions<cr>',   { silent = true, nowait = true, desc = 'Coc: [E]xtensions' })
map('n', '<space>cc', ':<C-u>CocList commands<cr>',     { silent = true, nowait = true, desc = 'Coc: [C]ommands' })
map('n', '<space>co', ':<C-u>CocList outline<cr>',      { silent = true, nowait = true, desc = 'Coc: [O]utline' })
map('n', '<space>cs', ':<C-u>CocList -I symbols<cr>',   { silent = true, nowait = true, desc = 'Coc: [S]ymbols' })
map('n', '<space>cj', ':<C-u>CocNext<CR>',              { silent = true, nowait = true, desc = 'Coc: Next item' })
map('n', '<space>ck', ':<C-u>CocPrev<CR>',              { silent = true, nowait = true, desc = 'Coc: Prev item' })
map('n', '<space>cp', ':<C-u>CocListResume<CR>',        { silent = true, nowait = true, desc = 'Coc: Resume list' })
map('n', '<space>y',  ':<C-u>CocList -A --normal yank<cr>', { silent = true, desc = 'Coc: Yank list' })
map('n', '<space>mp', ':<C-u>CocCommand markdown-preview-enhanced.openPreview<cr>', { silent = true, nowait = true, desc = 'Coc: Markdown preview' })

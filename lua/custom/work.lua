local map = vim.keymap.set
vim.o.grepprg = 'rg --vimgrep --no-heading --smart-case'
vim.g.floaterm_wintype = 'vsplit'
vim.g.floaterm_width = 0.33
vim.o.foldlevel = 99

map('v', '<C-R>', ':FloatermSend<cr>', { silent = true })

-- Open quickfix/location list after grep commands
local qf_group = vim.api.nvim_create_augroup('quickfix', { clear = true })
vim.api.nvim_create_autocmd('QuickFixCmdPost', {
  group = qf_group,
  pattern = '[^l]*',
  command = 'cwindow',
})
vim.api.nvim_create_autocmd('QuickFixCmdPost', {
  group = qf_group,
  pattern = 'l*',
  command = 'lwindow',
})
vim.api.nvim_create_autocmd('FileType', {
  group = qf_group,
  pattern = 'qf',
  command = 'wincmd J',
})

-- Navigate from terminal window to buffer windows
map('t', '<C-h>', '<C-\\><C-n><C-w>h', { silent = true })
map('t', '<C-j>', '<C-\\><C-n><C-w>j', { silent = true })
map('t', '<C-k>', '<C-\\><C-n><C-w>k', { silent = true })

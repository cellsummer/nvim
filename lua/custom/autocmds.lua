-- lua/custom/autocmds.lua
-- Custom autocommands

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

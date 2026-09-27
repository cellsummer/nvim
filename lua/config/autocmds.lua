-- lua/config/autocmds.lua
--
-- Autocommands not owned by a plugin. Every one belongs to an augroup with
-- `clear = true` so re-sourcing the config replaces them instead of stacking
-- duplicates.

local s = require 'config.settings'

local function group(name) return vim.api.nvim_create_augroup('config-' .. name, { clear = true }) end

-- Briefly highlight yanked text. Try it with `yap`.
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight on yank',
  group = group 'highlight-yank',
  callback = function() vim.hl.on_yank() end,
})

-- Open the quickfix or location list automatically after :grep / :make, and
-- keep the quickfix window full width at the bottom.
local qf = group 'quickfix'
vim.api.nvim_create_autocmd('QuickFixCmdPost', {
  desc = 'Open quickfix after grep',
  group = qf,
  pattern = '[^l]*',
  command = 'cwindow',
})
vim.api.nvim_create_autocmd('QuickFixCmdPost', {
  desc = 'Open location list after lgrep',
  group = qf,
  pattern = 'l*',
  command = 'lwindow',
})
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Move quickfix to the bottom, full width',
  group = qf,
  pattern = 'qf',
  command = 'wincmd J',
})

-- Keep `:help nvim-config` in sync: regenerate tags whenever the helpfile is
-- edited, so a new section is reachable without remembering :helptags.
vim.api.nvim_create_autocmd('BufWritePost', {
  desc = 'Regenerate helptags for this config',
  group = group 'helptags',
  pattern = vim.fn.stdpath 'config' .. '/doc/*.txt',
  callback = function() vim.cmd('helptags ' .. vim.fn.stdpath 'config' .. '/doc') end,
})

-- Remember the previous tab so <leader>tl can toggle back to it.
vim.g.lasttab = 1
vim.api.nvim_create_autocmd('TabLeave', {
  desc = 'Record the tab being left',
  group = group 'lasttab',
  callback = function() vim.g.lasttab = vim.fn.tabpagenr() end,
})

-- ============================================================
-- Terminal
-- ============================================================

local term = group 'terminal'

-- Editor chrome only gets in the way of a shell, and 'scrolloff' would hold the
-- prompt 20 lines above the bottom of the window. Terminal normal mode is the
-- opposite case: it exists to read scrollback with real motions, which wants
-- the line numbers back. So the chrome follows the mode.
local function term_chrome(state)
  local shown = state == 'shown'
  local lo = vim.opt_local
  lo.number, lo.relativenumber = shown, shown
  lo.signcolumn = shown and 'yes' or 'no'
  lo.cursorline = shown
end

vim.api.nvim_create_autocmd('TermOpen', {
  desc = 'Strip editor chrome from a terminal buffer',
  group = term,
  callback = function()
    term_chrome 'hidden'
    vim.opt_local.list = false
    vim.opt_local.spell = false
    vim.opt_local.scrolloff = 0
    vim.cmd.startinsert()
  end,
})

vim.api.nvim_create_autocmd('TermLeave', {
  desc = 'Show line numbers to read scrollback',
  group = term,
  callback = function() term_chrome 'shown' end,
})

vim.api.nvim_create_autocmd('TermEnter', {
  desc = 'Hide the chrome again on returning to the shell',
  group = term,
  callback = function() term_chrome 'hidden' end,
})

-- Neovide standing in for a terminal emulator: with no file to open, start on
-- a shell instead of an empty buffer. `nvim <file>` is untouched.
if vim.g.neovide and s.terminal_ui.enabled then
  vim.api.nvim_create_autocmd('VimEnter', {
    desc = 'Open a shell when Neovide starts with no file',
    group = group 'terminal-first',
    once = true,
    nested = true,
    callback = function()
      if vim.fn.argc() > 0 then return end
      vim.cmd 'FloatermNew --wintype=split --height=1.0'
      vim.cmd.only()
    end,
  })
end

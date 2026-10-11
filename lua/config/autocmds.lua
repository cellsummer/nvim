-- lua/config/autocmds.lua
--
-- Autocommands not owned by a plugin. Every one belongs to an augroup with
-- `clear = true` so re-sourcing the config replaces them instead of stacking
-- duplicates.

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

-- Terminal windows are for typing in. Covers :term and floaterm alike,
-- including an already-visible floaterm, which fires none of floaterm's own
-- autoinsert handling. <C-\><C-n> still sticks: that is a mode change inside
-- the window, not an entry into it.
--
-- One event per arrival path: TermOpen for a new terminal, BufEnter for a
-- buffer swap, WinEnter for a focus change.
vim.api.nvim_create_autocmd({ 'TermOpen', 'BufEnter', 'WinEnter' }, {
  desc = 'Enter terminal mode in terminal windows',
  group = group 'terminal-insert',
  callback = function(args)
    -- Hot path: these events fire on almost every window movement.
    if vim.bo[args.buf].buftype ~= 'terminal' then return end

    -- A dead job leaves the buffer unmodifiable, so insert mode errors out.
    -- jobwait with a 0 timeout returns -1 only while running.
    local job = vim.b[args.buf].terminal_job_id
    if not job or vim.fn.jobwait({ job }, 0)[1] ~= -1 then return end

    -- 'startinsert' is ignored while an autocommand runs, so defer it -- and
    -- recheck, because args.buf can be stale by then.
    vim.schedule(function()
      if vim.api.nvim_get_current_buf() == args.buf then vim.cmd.startinsert() end
    end)
  end,
})

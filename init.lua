-- Neovim configuration entry point.
--
-- This file only bootstraps. Nothing to configure here; the map is:
--
--   lua/config/settings.lua   every knob — theme, indent, paths, shell
--   lua/config/options.lua    vim options, set once from settings
--   lua/config/keymaps.lua    editor keymaps not owned by a plugin
--   lua/config/autocmds.lua   autocommands not owned by a plugin
--   lua/config/health.lua     :checkhealth config
--   lua/plugins/*.lua         one file per area; spec + its keymaps together
--
-- `:help nvim-config` for the full tour, `:Config` to jump to settings.lua.
--
-- Load order matters: lazy.setup runs plugin `config` functions first, then
-- config.keymaps runs. So a keymap set in config/keymaps.lua wins over a
-- plugin's. Leave keys a plugin owns to that plugin's file.

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', 'https://github.com/folke/lazy.nvim.git', lazypath }
  if vim.v.shell_error ~= 0 then error('Error cloning lazy.nvim:\n' .. out) end
end
vim.opt.rtp:prepend(lazypath)

require 'config.options'

require('lazy').setup({
  -- Every file under lua/plugins/ is a spec. Adding a plugin means adding it
  -- to the file for its area, or creating a new file there.
  { import = 'plugins' },
}, { ---@diagnostic disable-line: missing-fields
  -- An empty table keeps lazy's own Nerd Font icons; the fallback below is
  -- for terminals without one (settings.nerd_font = false).
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘', config = '🛠', event = '📅', ft = '📂', init = '⚙',
      keys = '🗝', plugin = '🔌', runtime = '💻', require = '🌙',
      source = '📄', start = '🚀', task = '📌', lazy = '💤 ',
    },
  },
  change_detection = { notify = false },
})

require 'config.keymaps'
require 'config.autocmds'

-- Jump straight to the file you edit most.
vim.api.nvim_create_user_command('Config', function() vim.cmd.edit(vim.fn.stdpath 'config' .. '/lua/config/settings.lua') end, { desc = 'Edit config/settings.lua' })

-- Neovim 0.12+ experimental UI (better messages, cmdline, pager)
pcall(function() require('vim._core.ui2').enable {} end)

-- vim: ts=2 sts=2 sw=2 et

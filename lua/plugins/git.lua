-- lua/plugins/git.lua
--
-- Keymaps
--   ]c [c          next / previous hunk
--   <leader>h      hunk actions: stage, reset, preview, blame, diff
--   <leader>g      git pickers (branches, log, status, stash) — see picker.lua
--   :Git ...       fugitive
--   :GBrowse       open the current line on the remote host
--
-- The Bitbucket host for :GBrowse is set in config/settings.lua.

local s = require 'config.settings'

---@module 'lazy'
---@type LazySpec
return {
  {
    'lewis6991/gitsigns.nvim',
    ---@module 'gitsigns'
    ---@type Gitsigns.Config
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      signs = {
        add = { text = '+' }, ---@diagnostic disable-line: missing-fields
        change = { text = '~' }, ---@diagnostic disable-line: missing-fields
        delete = { text = '_' }, ---@diagnostic disable-line: missing-fields
        topdelete = { text = '‾' }, ---@diagnostic disable-line: missing-fields
        changedelete = { text = '~' }, ---@diagnostic disable-line: missing-fields
      },
      on_attach = function(bufnr)
        local gs = require 'gitsigns'

        local function map(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc }) end

        -- In a diff split, ]c/[c already mean "next change"; defer to it.
        map('n', ']c', function()
          if vim.wo.diff then return vim.cmd.normal { ']c', bang = true } end
          gs.nav_hunk 'next'
        end, 'Jump to next git [c]hange')

        map('n', '[c', function()
          if vim.wo.diff then return vim.cmd.normal { '[c', bang = true } end
          gs.nav_hunk 'prev'
        end, 'Jump to previous git [c]hange')

        map('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' } end, 'git [s]tage hunk')
        map('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' } end, 'git [r]eset hunk')
        map('n', '<leader>hs', gs.stage_hunk, 'git [s]tage hunk')
        map('n', '<leader>hr', gs.reset_hunk, 'git [r]eset hunk')
        map('n', '<leader>hS', gs.stage_buffer, 'git [S]tage buffer')
        map('n', '<leader>hu', gs.stage_hunk, 'git [u]ndo stage hunk')
        map('n', '<leader>hR', gs.reset_buffer, 'git [R]eset buffer')
        map('n', '<leader>hp', gs.preview_hunk, 'git [p]review hunk')
        map('n', '<leader>hb', gs.blame_line, 'git [b]lame line')
        map('n', '<leader>hd', gs.diffthis, 'git [d]iff against index')
        map('n', '<leader>hD', function() gs.diffthis '@' end, 'git [D]iff against last commit')

        -- Toggles live under <leader>h too; <leader>t is the tab group.
        map('n', '<leader>hB', gs.toggle_current_line_blame, 'git toggle line [B]lame')
        map('n', '<leader>hV', gs.preview_hunk_inline, 'git toggle deleted ([V]iew inline)')
      end,
    },
  },

  'tpope/vim-fugitive',

  -- Teaches :GBrowse about the internal Bitbucket host
  {
    'tommcdo/vim-fubitive',
    dependencies = { 'tpope/vim-fugitive' },
    init = function()
      vim.g.fubitive_domain_pattern = s.bitbucket.domain
      vim.g.fubitive_default_protocol = s.bitbucket.protocol
    end,
  },
}

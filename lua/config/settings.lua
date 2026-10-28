-- lua/config/settings.lua
--
-- Every knob this config exposes, in one table. Start here: the things that
-- change most often (theme, indent, paths, shell) are all below, and the rest
-- of the config reads them from this module rather than hardcoding values.
--
-- See `:help nvim-config` for the full layout, and `:checkhealth config` to
-- see which of these settings are live and which point at something missing.

local is_win = vim.fn.has 'win32' == 1

local M = {}

-- Platform flags. Prefer these over repeating `vim.fn.has 'win32'`.
M.os = {
  win = is_win,
  mac = vim.fn.has 'mac' == 1,
}

-- ============================================================
-- Appearance
-- ============================================================

-- Installed themes: token, token-flint, token-ultra, token-meridian,
-- token-temper, predawn, nordic, ember, ember-soft, ember-light, codedark.
-- The token family picks dark or light from 'background'.
-- Preview them live with <leader>ft before committing to one here.
M.colorscheme = 'token-flint'

-- Nerd Font installed and selected in the terminal / Neovide.
M.nerd_font = true

-- ============================================================
-- Editing
-- ============================================================

M.indent = {
  width = 4,
  expandtab = true,
}

M.scrolloff = 20
M.textwidth = 500

-- 'unix,dos' reads CRLF files without complaint but writes LF for new files.
M.fileformats = 'unix,dos'

-- Inherited from _vimrc: with magic off, `.` `*` `[` are literal in patterns.
-- Neovim's docs recommend against it and some plugins assume it is on. Flip to
-- true if a plugin's :s or search starts behaving strangely.
M.magic_search = false

-- ============================================================
-- Paths
-- ============================================================

-- Targets for the <leader>s and <leader>f pickers. A directory that does not
-- exist is reported by `:checkhealth config`, not silently ignored.
M.dirs = {
  notes = '~/Notes',
  scripts = is_win and '~/bin/Scripts' or '~/bin',
  temp = is_win and 'c:/tmp' or '/tmp',
}

-- ============================================================
-- Terminal
-- ============================================================

-- Shell for :term buffers and floaterm. 'cmd', 'pwsh', 'bash', 'zsh', ...
M.shell = is_win and 'cmd' or (vim.env.SHELL or 'bash')

-- Floating terminal geometry (fractions of the editor).
M.floaterm = {
  width = 0.33, -- vsplit width, used by <C-/>
  float_width = 0.8, -- <leader>uf

  -- How <leader>la writes the selected code's location into the terminal,
  -- for a coding agent running there to read. The path comes first, relative
  -- to the cwd, then the line numbers.
  code_ref = {
    line = '@%s#L%d',
    range = '@%s#L%d-L%d',
  },
}

-- ============================================================
-- Work-specific
-- ============================================================

-- Teaches vim-fugitive's :GBrowse about the internal Bitbucket host.
M.bitbucket = {
  domain = 'bitbucket\\.us\\.aegon\\.com',
  protocol = 'http://',
}

-- ============================================================
-- Treesitter
-- ============================================================

-- Parsers installed on startup. Add a language name here and restart; the
-- treesitter `main` branch installs it on the next launch.
M.treesitter_parsers = {
  'bash',
  'c',
  'diff',
  'html',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'python',
  'query',
  'vim',
  'vimdoc',
}

-- ============================================================
-- Leader key groups
-- ============================================================

-- Drives the mini.clue popup: press <leader> and these are the headings you
-- see. Add a line whenever you start a new <leader>X* family.
--
-- RULE: a group prefix must never also be a mapping of its own. mini.clue
-- ignores 'timeoutlen', so if both `<leader>a` and `<leader>ac` exist, the
-- longer one stops firing without an extra <CR>. Keep every binding a leaf.
--
-- Entries are { key, description, modes } with modes defaulting to n + x.
M.leader_groups = {
  { 'a', '+Code [A]ction' },
  { 'b', '+[B]uffer & Term' },
  { 'c', '+[C]oc' },
  { 'd', '+[D]ebug' },
  { 'f', '+[F]ind' },
  { 'g', '+[G]it' },
  { 'h', '+Git [H]unk', { 'n', 'v' } },
  { 'l', '+[L]SP & Run' },
  { 'm', '+[M]arkdown & Misc' },
  { 'p', '+[P]aste' },
  { 'r', '+[R]efactor' },
  { 's', '+[S]earch', { 'n', 'v' } },
  { 't', '+[T]ab' },
  { 'u', '+[U]I & Terminals' },
}

return M

-- lua/plugins/picker.lua
--
-- snacks.nvim is the picker and file explorer for everything: files, buffers,
-- grep, git, LSP symbols. It replaced telescope.
--
-- Keymaps
--   <leader><leader>  files        <C-p>       buffers
--   <leader>f         find group   <leader>s   search group
--   <leader>g         git group    <leader>e   file explorer
--   gr* / gO / gW     LSP navigation
--
-- Inside a picker, <C-o> opens the entry with the system handler.
--
-- The directories behind <leader>sn / <leader>fs / <leader>st come from
-- config/settings.lua. `:checkhealth config` flags any that do not exist.

local s = require 'config.settings'

-- Open a picker rooted at one of the configured directories.
local function files_in(dir)
  return function() Snacks.picker.files { cwd = vim.fn.expand(dir) } end
end

---@module 'lazy'
---@type LazySpec
return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      picker = {
        enabled = true,
        actions = {
          -- Hand the entry to the OS (open a PDF, an image, a URL) rather
          -- than loading it into a buffer.
          open_with_system = function(picker, item)
            if not item or not item.file then return end
            local path = item.file
            local is_absolute = path:match '^%a:' or path:match '^/'
            if not is_absolute then path = vim.fn.fnamemodify(path, ':p') end
            picker:close()
            vim.ui.open(path)
          end,
        },
        formatters = {
          file = { filename_first = true, truncate = 40 },
        },
        win = {
          input = { keys = { ['<C-o>'] = { 'open_with_system', mode = { 'n', 'i' } } } },
          list = { keys = { ['<C-o>'] = 'open_with_system' } },
        },
      },
    },
    keys = {
      -- Files and buffers
      { '<leader><leader>', function() Snacks.picker.files { ignored = true } end, desc = 'Find Files (incl. ignored)' },
      { '<C-p>', function() Snacks.picker.buffers() end, desc = 'Find Buffers' },
      { '<leader>e', function() Snacks.explorer() end, desc = 'File [E]xplorer' },

      -- Find group
      { '<leader>ff', function() Snacks.picker.git_files() end, desc = '[F]ind Git [F]iles' },
      { '<leader>fg', function() Snacks.picker.git_status() end, desc = '[F]ind [G]it Status' },
      { '<leader>fb', function() Snacks.picker.buffers() end, desc = '[F]ind [B]uffers' },
      { '<leader>fj', function() Snacks.picker.jumps() end, desc = '[F]ind [J]umplist' },
      { '<leader>f;', function() Snacks.picker.command_history() end, desc = '[F]ind Command History' },
      { '<leader>fw', function() Snacks.picker.grep() end, desc = '[F]ind by grep [W]ord' },
      { '<leader>ft', function() Snacks.picker.colorschemes() end, desc = '[F]ind [T]heme (preview live)' },
      { '<leader>fn', files_in(vim.fn.stdpath 'config'), desc = '[F]ind [N]eovim config files' },
      { '<leader>fs', files_in(s.dirs.scripts), desc = '[F]ind [S]cripts' },

      -- Search group
      { '<leader>/', function() Snacks.picker.lines() end, desc = '[/] Fuzzily search in current buffer' },
      { '<leader>s/', function() Snacks.picker.grep_buffers() end, desc = '[S]earch [/] in Open Files' },
      { '<leader>sc', function() Snacks.picker.commands() end, desc = '[S]earch [C]ommands' },
      { '<leader>sd', function() Snacks.picker.diagnostics() end, desc = '[S]earch [D]iagnostics' },
      { '<leader>sf', function() Snacks.picker.files() end, desc = '[S]earch [F]iles' },
      { '<leader>sg', function() Snacks.picker.grep() end, desc = '[S]earch by [G]rep' },
      { '<leader>sh', function() Snacks.picker.help() end, desc = '[S]earch [H]elp' },
      { '<leader>sk', function() Snacks.picker.keymaps() end, desc = '[S]earch [K]eymaps' },
      { '<leader>sr', function() Snacks.picker.resume() end, desc = '[S]earch [R]esume' },
      { '<leader>ss', function() Snacks.picker.smart() end, desc = '[S]earch [S]mart' },
      { '<leader>so', function() Snacks.picker.recent() end, desc = '[S]earch [O]ld/Recent Files' },
      { '<leader>sw', function() Snacks.picker.grep_word() end, desc = '[S]earch current [W]ord', mode = { 'n', 'v' } },
      { '<leader>sn', files_in(s.dirs.notes), desc = '[S]earch [N]otes' },
      { '<leader>st', files_in(s.dirs.temp), desc = '[S]earch [T]emp folder' },

      -- Git group
      { '<leader>gb', function() Snacks.picker.git_branches() end, desc = 'Git Branches' },
      { '<leader>gl', function() Snacks.picker.git_log() end, desc = 'Git Log' },
      { '<leader>gL', function() Snacks.picker.git_log_line() end, desc = 'Git Log Line' },
      { '<leader>gs', function() Snacks.picker.git_status() end, desc = 'Git Status' },
      { '<leader>gS', function() Snacks.picker.git_stash() end, desc = 'Git Stash' },
      { '<leader>gd', function() Snacks.picker.git_diff() end, desc = 'Git Diff (Hunks)' },
      { '<leader>gf', function() Snacks.picker.git_log_file() end, desc = 'Git Log File' },

      -- LSP navigation. coc.nvim owns gd/gy/gr (see coc.lua); these are the
      -- picker-backed variants for when you want to browse the results.
      { 'grd', function() Snacks.picker.lsp_definitions() end, desc = '[G]oto [D]efinition' },
      { 'grr', function() Snacks.picker.lsp_references() end, desc = '[G]oto [R]eferences' },
      { 'gri', function() Snacks.picker.lsp_implementations() end, desc = '[G]oto [I]mplementation' },
      { 'grt', function() Snacks.picker.lsp_type_definitions() end, desc = '[G]oto [T]ype Definition' },
      { 'gO', function() Snacks.picker.lsp_symbols() end, desc = 'Open Document Symbols' },
      { 'gW', function() Snacks.picker.lsp_workspace_symbols() end, desc = 'Open Workspace Symbols' },
    },
  },
}

---@module 'lazy'
---@type LazySpec
return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      picker = { enabled = true },
    },
    keys = {
      { '<leader>sh', function() Snacks.picker.help() end, desc = '[S]earch [H]elp' },
      { '<leader>sk', function() Snacks.picker.keymaps() end, desc = '[S]earch [K]eymaps' },
      { '<leader>sf', function() Snacks.picker.files() end, desc = '[S]earch [F]iles' },
      { '<leader>ss', function() Snacks.picker.pickers() end, desc = '[S]earch [S]elect Picker' },
      { '<leader>sw', function() Snacks.picker.grep_word() end, desc = '[S]earch current [W]ord', mode = { 'n', 'v' } },
      { '<leader>sg', function() Snacks.picker.grep() end, desc = '[S]earch by [G]rep' },
      { '<leader>sd', function() Snacks.picker.diagnostics() end, desc = '[S]earch [D]iagnostics' },
      { '<leader>sr', function() Snacks.picker.resume() end, desc = '[S]earch [R]esume' },
      { '<leader>sc', function() Snacks.picker.commands() end, desc = '[S]earch [C]ommands' },
      { '<leader>/', function() Snacks.picker.lines() end, desc = '[/] Fuzzily search in current buffer' },
      { '<leader>s/', function() Snacks.picker.grep_buffers() end, desc = '[S]earch [/] in Open Files' },
      { '<leader>sn', function() Snacks.picker.files { cwd = vim.fn.stdpath 'config' } end, desc = '[S]earch [N]eovim files' },
      -- LSP
      { 'grd', function() Snacks.picker.lsp_definitions() end, desc = '[G]oto [D]efinition' },
      { 'grr', function() Snacks.picker.lsp_references() end, desc = '[G]oto [R]eferences' },
      { 'gri', function() Snacks.picker.lsp_implementations() end, desc = '[G]oto [I]mplementation' },
      { 'grt', function() Snacks.picker.lsp_type_definitions() end, desc = '[G]oto [T]ype Definition' },
      { 'gO', function() Snacks.picker.lsp_symbols() end, desc = 'Open Document Symbols' },
      { 'gW', function() Snacks.picker.lsp_workspace_symbols() end, desc = 'Open Workspace Symbols' },
    },
  },
}

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
          open_with_system = function(picker, item)
            if item and item.file then
              local path = vim.fn.fnamemodify(item.file, ':p')
              vim.ui.open(path)
              picker:close()
            end
          end,
        },
        formatters = {
          file = {
            filename_first = true, -- or true if you prefer filename first
            truncate = 40,
          }
        },
        win = {
          input = {
            keys = {
              ['<C-o>'] = { 'open_with_system', mode = { 'n', 'i' } },
            },
          },
          list = {
            keys = {
              ['<C-o>'] = 'open_with_system',
            },
          },
        },
      },
    },
    keys = {
      -- File/buffer pickers
      { '<leader><leader>', function() Snacks.picker.files({ignored = true}) end, desc = 'Find Files' },
      { '<C-p>', function() Snacks.picker.buffers() end, desc = 'Find Buffers' },
      { '<leader>ff', function() Snacks.picker.git_files() end, desc = '[F]ind Git [F]iles' },
      { '<leader>fg', function() Snacks.picker.git_status() end, desc = '[F]ind [G]it Status' },
      { '<leader>fb', function() Snacks.picker.buffers() end, desc = '[F]ind [B]uffers' },
      { '<leader>fj', function() Snacks.picker.jumps() end, desc = '[F]ind [J]umplist' },
      { '<leader>f;', function() Snacks.picker.command_history() end, desc = '[F]ind Command History' },
      { '<leader>fw', function() Snacks.picker.grep() end, desc = '[F]ind by grep [W]ord' },
      { '<leader>ft', function() Snacks.picker.colorschemes() end, desc = '[F]ind [T]heme/Colorscheme' },
      { '<leader>so', function() Snacks.picker.recent() end, desc = '[S]earch [O]ld/Recent Files' },
      -- Search
      { '<leader>sh', function() Snacks.picker.help() end, desc = '[S]earch [H]elp' },
      { '<leader>sk', function() Snacks.picker.keymaps() end, desc = '[S]earch [K]eymaps' },
      { '<leader>sf', function() Snacks.picker.files() end, desc = '[S]earch [F]iles' },
      { '<leader>ss', function() Snacks.picker.smart() end, desc = '[S]earch [S]mart' },
      { '<leader>sw', function() Snacks.picker.grep_word() end, desc = '[S]earch current [W]ord', mode = { 'n', 'v' } },
      { '<leader>sg', function() Snacks.picker.grep() end, desc = '[S]earch by [G]rep' },
      { '<leader>sd', function() Snacks.picker.diagnostics() end, desc = '[S]earch [D]iagnostics' },
      { '<leader>sr', function() Snacks.picker.resume() end, desc = '[S]earch [R]esume' },
      { '<leader>sc', function() Snacks.picker.commands() end, desc = '[S]earch [C]ommands' },
      { '<leader>/', function() Snacks.picker.lines() end, desc = '[/] Fuzzily search in current buffer' },
      { '<leader>s/', function() Snacks.picker.grep_buffers() end, desc = '[S]earch [/] in Open Files' },
      { '<leader>sn', function() Snacks.picker.files { cwd = vim.fn.stdpath 'config' } end, desc = '[S]earch [N]eovim files' },
      { "<leader>e", function() Snacks.explorer() end, desc = "File [E]xplorer" },
      -- Git
      { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
      { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
      { "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
      { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
      { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
      { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (Hunks)" },
      { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },
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

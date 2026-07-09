-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

---@module 'lazy'
---@type LazySpec
return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    -- NOTE: keep <leader>e a leaf. mini.clue ignores 'timeoutlen', so if any
    -- <leader>e* mapping exists this stops firing until you press <CR>.
    { '<leader>e', '<cmd>Neotree toggle left<cr>', desc = 'Toggle [E]xplorer (left)', silent = true },
    -- Replaces netrw :Vex and vim-vinegar's `-`
    { '-', '<cmd>Neotree reveal left<cr>', desc = 'Explorer at current file', silent = true },
    { '\\', '<cmd>Neotree reveal<cr>', desc = 'NeoTree reveal', silent = true },
  },
  -- The netrw hijack lives inside neo-tree, so it can't fire while the plugin
  -- is still lazy. This hook watches for a directory buffer (`:e some/dir/`,
  -- `<leader>te`, `nvim .`) and loads neo-tree on demand, then removes itself.
  init = function()
    vim.api.nvim_create_autocmd('BufEnter', {
      group = vim.api.nvim_create_augroup('NeoTreeHijackNetrw', { clear = true }),
      callback = function()
        local path = vim.fn.expand '%:p'
        if path ~= '' and vim.fn.isdirectory(path) == 1 then
          vim.api.nvim_clear_autocmds { group = 'NeoTreeHijackNetrw' }
          vim.cmd('Neotree current dir=' .. vim.fn.fnameescape(path))
        end
      end,
    })
  end,
  ---@module 'neo-tree'
  ---@type neotree.Config
  opts = {
    -- Takes over directory buffers once loaded, so netrw never renders them.
    filesystem = {
      hijack_netrw_behavior = 'open_default',
      window = {
        mappings = {
          ['\\'] = 'close_window',
          ['-'] = 'navigate_up',
        },
      },
      -- Left at default (false): the libuv watcher is a known memory sink on
      -- Windows with large trees. Neo-tree falls back to autocmd refresh.
      use_libuv_file_watcher = false,
    },
  },
}

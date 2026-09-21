-- lua/plugins/treesitter.lua
--
-- Syntax highlighting and indentation from a real parse tree.
-- The parser list is config.settings.treesitter_parsers — add a language
-- there and restart; it installs on the next launch.

local s = require 'config.settings'

---@module 'lazy'
---@type LazySpec
return {
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    branch = 'main', -- the `main` branch drops the old setup{} API
    config = function()
      require('nvim-treesitter').install(s.treesitter_parsers)

      -- The `main` branch does not attach itself; start the parser per buffer.
      vim.api.nvim_create_autocmd('FileType', {
        desc = 'Start treesitter for the buffer filetype',
        group = vim.api.nvim_create_augroup('config-treesitter', { clear = true }),
        callback = function(args)
          local language = vim.treesitter.language.get_lang(args.match)
          if not language then return end
          if not vim.treesitter.language.add(language) then return end

          vim.treesitter.start(args.buf, language)
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

          -- Treesitter folds are available but 'foldmethod' is set to indent
          -- in config/options.lua. To switch, set these here instead:
          --   vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          --   vim.wo.foldmethod = 'expr'
        end,
      })
    end,
  },
}

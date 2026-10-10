-- lua/plugins/treesitter.lua
--
-- Syntax highlighting, indentation and folding from a real parse tree.
-- The parser list is config.settings.treesitter_parsers — add a language
-- there and restart; it installs on the next launch.
--
-- Filetypes with a parser fold on the tree; the rest fall back to the
-- 'indent' foldmethod set in config/options.lua.

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

          -- Fold on the parse tree. Only filetypes that get this far have a
          -- parser, so everything else keeps the 'indent' foldmethod from
          -- config/options.lua.
          --
          -- The [0][0] index is `:setlocal` for a window option: the value
          -- sticks to this buffer rather than the window, so opening an
          -- unparsed file in the same window does not inherit an expr
          -- foldmethod with no parser behind it.
          vim.wo[0][0].foldmethod = 'expr'
          vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        end,
      })
    end,
  },
}

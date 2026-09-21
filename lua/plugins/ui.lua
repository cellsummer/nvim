-- lua/plugins/ui.lua
--
-- Statusline, key hints, text objects and comment highlighting.
--
-- The key hint popup (mini.clue) reads its group headings from
-- config.settings.leader_groups — add a group there, not here.

local s = require 'config.settings'

---@module 'lazy'
---@type LazySpec
return {
  {
    'nvim-mini/mini.nvim',
    config = function()
      -- Around/inside text objects: va) yinq ci'
      require('mini.ai').setup { n_lines = 500 }

      -- mini.surround stays off; tpope/vim-surround owns cs/ds/ys.

      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = s.nerd_font }
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function() return '%2l:%-2v' end

      -- mini.clue only wraps keys that are not already mapped, so claim Q
      -- first to stop it shadowing the macro-replay key.
      vim.keymap.set('n', 'Q', 'Q', { nowait = true, desc = 'Replay last macro' })

      local miniclue = require 'mini.clue'

      -- Expand settings.leader_groups into one clue per mode.
      local clues = {}
      for _, entry in ipairs(s.leader_groups) do
        local key, desc, modes = entry[1], entry[2], entry[3] or { 'n', 'x' }
        for _, mode in ipairs(modes) do
          table.insert(clues, { mode = mode, keys = '<Leader>' .. key, desc = desc })
        end
      end
      table.insert(clues, { mode = 'n', keys = 'gr', desc = '+LSP [R]eferences' })

      vim.list_extend(clues, {
        miniclue.gen_clues.builtin_completion(),
        miniclue.gen_clues.g(),
        miniclue.gen_clues.marks(),
        miniclue.gen_clues.registers(),
        miniclue.gen_clues.windows(),
        miniclue.gen_clues.z(),
      })

      miniclue.setup {
        window = { delay = 0 },
        triggers = {
          { mode = 'n', keys = '<Leader>' },
          { mode = 'x', keys = '<Leader>' },
          { mode = 'n', keys = 'g' },
          { mode = 'x', keys = 'g' },
          { mode = 'n', keys = "'" },
          { mode = 'x', keys = "'" },
          { mode = 'n', keys = '`' },
          { mode = 'x', keys = '`' },
          { mode = 'n', keys = '"' },
          { mode = 'x', keys = '"' },
          { mode = 'i', keys = '<C-r>' },
          { mode = 'c', keys = '<C-r>' },
          { mode = 'n', keys = '<C-w>' },
          { mode = 'n', keys = 'z' },
          { mode = 'x', keys = 'z' },
          { mode = 'n', keys = '[' },
          { mode = 'n', keys = ']' },
        },
        clues = clues,
      }
    end,
  },

  -- which-key is superseded by mini.clue above. Kept disabled rather than
  -- removed so a stray :Lazy install does not reintroduce two hint popups.
  { 'folke/which-key.nvim', enabled = false },

  -- Highlight TODO / FIXME / NOTE in comments
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    ---@module 'todo-comments'
    ---@type TodoOptions
    ---@diagnostic disable-next-line: missing-fields
    opts = { signs = false },
  },
}

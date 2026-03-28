vim.keymap.set('i', 'jk', '<Esc>')

local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader><leader>', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<C-p>', builtin.buffers, { desc = '[ ] Find existing buffers' })

-- lua/plugins/markdown.lua
--
-- Keymaps
--   <leader>mi  paste an image from the clipboard as a markdown link
--   <leader>mp  open the coc markdown preview
--
-- Fenced code block languages and folding are set in config/options.lua.

---@module 'lazy'
---@type LazySpec
return {
  {
    'HakonHarnes/img-clip.nvim',
    event = 'VeryLazy',
    opts = {},
    keys = {
      { '<leader>mi', '<cmd>PasteImage<cr>', desc = 'Paste [M]arkdown [I]mage' },
      {
        '<leader>mp',
        '<cmd>CocCommand markdown-preview-enhanced.openPreview<cr>',
        silent = true,
        desc = '[M]arkdown [P]review',
      },
    },
  },
}

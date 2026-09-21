-- lua/plugins/colorscheme.lua
--
-- Themes. Every one is lazy except the active choice, so switching costs a
-- single edit in config/settings.lua (`M.colorscheme`) and a restart.
-- Preview them live first with <leader>ft.
--
-- Available: predawn, nordic, ember, ember-soft, ember-light, codedark

local s = require 'config.settings'

-- Predawn does not define float or picker groups, and leaves the statusline
-- emphasising the git branch over the file path. Fix both after it loads.
local function predawn_overrides()
  local hl = vim.api.nvim_set_hl
  hl(0, 'NormalFloat', { fg = '#F1F1F1', bg = '#232323' })
  hl(0, 'FloatBorder', { fg = '#777777', bg = '#232323' })
  hl(0, 'FloatTitle', { fg = '#F18260', bg = '#232323', bold = true })
  hl(0, 'SnacksPickerDir', { fg = '#92BFBF' })
  hl(0, 'MiniStatuslineFilename', { link = 'StatusLine' })
  hl(0, 'MiniStatuslineDevinfo', { link = 'StatusLineNC' })
end

local active = s.colorscheme

---@module 'lazy'
---@type LazySpec
return {
  {
    'cellsummer/vim-colors', -- provides predawn
    lazy = active ~= 'predawn',
    priority = 1000,
    config = function()
      vim.o.termguicolors = true
      vim.g.predawn_disable_italic = 1
      if active == 'predawn' then
        vim.cmd.colorscheme 'predawn'
        predawn_overrides()
      end
    end,
  },

  {
    'AlexvZyl/nordic.nvim',
    lazy = active ~= 'nordic',
    priority = 1000,
    config = function()
      local c = require 'nordic.colors'
      require('nordic').load {
        nordic = { reduced_blue = true },
        override = { Visual = { bg = c.gray2 } },
      }
    end,
  },

  {
    'ember-theme/nvim',
    name = 'ember',
    lazy = not vim.startswith(active, 'ember'),
    priority = 1000,
    config = function()
      local variant = vim.startswith(active, 'ember') and active or 'ember'
      require('ember').setup { variant = variant }
      if vim.startswith(active, 'ember') then vim.cmd.colorscheme 'ember' end
    end,
  },

  {
    'tomasiser/vim-code-dark',
    lazy = active ~= 'codedark',
    priority = 1000,
    config = function()
      if active == 'codedark' then vim.cmd.colorscheme 'codedark' end
    end,
  },

  -- Render #rrggbb and rgb() literals in their own colour
  { 'norcalli/nvim-colorizer.lua', opts = {} },
}

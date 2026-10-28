-- lua/plugins/colorscheme.lua
--
-- Themes. Every one is lazy except the active choice, so switching costs a
-- single edit in config/settings.lua (`M.colorscheme`) and a restart.
-- Preview them live first with <leader>ft.
--
-- Available: token, token-flint, token-ultra, token-meridian, token-temper,
--            predawn, nordic, ember, ember-soft, ember-light, codedark

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
    "wtfox/luna.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
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
    'ThorstenRhau/token',
    version = '*', -- tagged releases, not untagged commits on main
    lazy = not vim.startswith(active, 'token'),
    priority = 1000,
    config = function()
      -- Integrations are opt-in since v2; these are the supported plugins
      -- this config actually loads. Dark or light comes from 'background'.
      require('token').setup {
        -- A global gate: applied last, so it also covers plugin groups and
        -- any override, not just the stock italic comments and quotes.
        attributes = { italic = false },
        plugins = {
          dap_ui = true,
          flash = true,
          fugitive = true,
          gitsigns = true,
          lazy = true,
          mason = true,
          mini = true,
          snacks = true,
          todo_comments = true,
        },
      }
      -- 'token', 'token-flint', 'token-ultra', ... are all valid names, so
      -- the setting doubles as the appearance.
      if vim.startswith(active, 'token') then vim.cmd.colorscheme(active) end
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

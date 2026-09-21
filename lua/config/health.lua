-- lua/config/health.lua
--
-- `:checkhealth config` reports what this configuration is actually doing:
-- which settings are live, whether the paths in config/settings.lua exist,
-- and whether the external programs it depends on are installed.

local s = require 'config.settings'

local H = {}

-- External programs, and what stops working without each.
local REQUIREMENTS = {
  { exe = 'git', why = 'lazy.nvim plugin installs, fugitive, gitsigns' },
  { exe = 'rg', why = "':grep' and every snacks grep picker" },
  { exe = 'node', why = 'coc.nvim — completion and diagnostics do not start without it' },
  { exe = 'python', why = 'nvim-dap-python, unless a project venv is active' },
  { exe = 'unzip', why = 'mason package installs' },
}

local function check_version()
  local version = tostring(vim.version())
  if vim.version.ge and vim.version.ge(vim.version(), '0.11') then
    vim.health.ok('Neovim ' .. version)
  else
    vim.health.error(('Neovim %s is too old; this config targets 0.11+'):format(version))
  end
end

local function check_requirements()
  for _, req in ipairs(REQUIREMENTS) do
    if vim.fn.executable(req.exe) == 1 then
      vim.health.ok(('%s — %s'):format(req.exe, req.why))
    else
      vim.health.warn(('%s not found — %s'):format(req.exe, req.why))
    end
  end
end

local function check_dirs()
  for name, dir in pairs(s.dirs) do
    local path = vim.fn.expand(dir)
    if vim.fn.isdirectory(path) == 1 then
      vim.health.ok(('dirs.%s -> %s'):format(name, path))
    else
      vim.health.warn(('dirs.%s -> %s does not exist'):format(name, dir), { 'Fix or remove it in lua/config/settings.lua' })
    end
  end
end

local function check_colorscheme()
  local active = vim.g.colors_name
  if active == nil then
    vim.health.error 'No colorscheme loaded'
  elseif s.colorscheme == active or vim.startswith(s.colorscheme, active) then
    vim.health.ok(('colorscheme %s'):format(active))
  else
    vim.health.warn(("settings.colorscheme is '%s' but '%s' is loaded"):format(s.colorscheme, active))
  end
end

local function check_settings()
  vim.health.info(('platform: %s'):format(s.os.win and 'windows' or (s.os.mac and 'macos' or 'linux')))
  vim.health.info(('shell: %s'):format(s.shell))
  vim.health.info(('indent: %d %s'):format(s.indent.width, s.indent.expandtab and 'spaces' or 'tabs'))
  vim.health.info(('treesitter parsers: %s'):format(table.concat(s.treesitter_parsers, ', ')))

  if not s.magic_search then
    vim.health.warn("'magic' is off — `.` `*` `[` are literal in patterns", {
      'Inherited from _vimrc. Some plugins assume magic is on.',
      'Set magic_search = true in lua/config/settings.lua if :s or search misbehaves.',
    })
  end
end

local function check_coc()
  if vim.fn.exists '*CocAction' == 0 then
    vim.health.warn 'coc.nvim is not loaded yet; open a file and re-run this check'
    return
  end

  local ok, extensions = pcall(vim.fn.CocAction, 'extensionStats')
  if not ok or type(extensions) ~= 'table' then
    vim.health.warn('The coc service is not running yet', {
      'Normal in a headless or freshly started session.',
      'Open a file, wait for coc to attach, then re-run :checkhealth config.',
    })
    return
  end

  local loaded, disabled = {}, {}
  for _, ext in ipairs(extensions) do
    table.insert(ext.state == 'disabled' and disabled or loaded, ext.id)
  end

  vim.health.ok(('coc extensions: %s'):format(table.concat(loaded, ', ')))
  if #disabled > 0 then vim.health.info(('disabled: %s'):format(table.concat(disabled, ', '))) end
end

function H.check()
  vim.health.start 'config: environment'
  check_version()
  check_requirements()

  vim.health.start 'config: settings.lua'
  check_settings()
  check_colorscheme()
  check_dirs()

  vim.health.start 'config: coc.nvim'
  check_coc()
end

return H

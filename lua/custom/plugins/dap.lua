-- lua/custom/plugins/dap.lua
-- Python debugging via nvim-dap + debugpy (installed by mason).
-- All keymaps live under <Leader>d — see the '+Debug' clue in init.lua.

-- debugpy is installed by mason into its own venv; point dap-python at that
-- interpreter so it never depends on whatever venv the project has active.
local function debugpy_python()
  local root = vim.fn.stdpath 'data' .. '/mason/packages/debugpy/venv'
  local exe = vim.fn.has 'win32' == 1 and root .. '/Scripts/python.exe' or root .. '/bin/python'
  if vim.fn.executable(exe) == 1 then return exe end
  return vim.fn.exepath 'python' ~= '' and 'python' or 'python3'
end

---@module 'lazy'
---@type LazySpec
return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio', -- required by nvim-dap-ui
    'mfussenegger/nvim-dap-python',

    -- Installs debugpy for you
    { 'mason-org/mason.nvim', opts = {} },
    'jay-babu/mason-nvim-dap.nvim',
  },
  keys = {
    -- Stepping / flow control
    { '<leader>dc', function() require('dap').continue() end, desc = '[D]ebug: [C]ontinue / Start' },
    { '<leader>di', function() require('dap').step_into() end, desc = '[D]ebug: Step [I]nto' },
    { '<leader>do', function() require('dap').step_over() end, desc = '[D]ebug: Step [O]ver' },
    { '<leader>dO', function() require('dap').step_out() end, desc = '[D]ebug: Step [O]ut' },
    { '<leader>dj', function() require('dap').run_to_cursor() end, desc = '[D]ebug: Run to cursor' },
    { '<leader>dl', function() require('dap').run_last() end, desc = '[D]ebug: Run [L]ast' },
    { '<leader>dx', function() require('dap').terminate() end, desc = '[D]ebug: Terminate' },

    -- Breakpoints
    { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = '[D]ebug: Toggle [B]reakpoint' },
    { '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, desc = '[D]ebug: Conditional [B]reakpoint' },
    { '<leader>dg', function() require('dap').set_breakpoint(nil, nil, vim.fn.input 'Log message: ') end, desc = '[D]ebug: Lo[g] point' },
    { '<leader>dC', function() require('dap').clear_breakpoints() end, desc = '[D]ebug: [C]lear breakpoints' },

    -- Inspecting state
    { '<leader>du', function() require('dapui').toggle() end, desc = '[D]ebug: Toggle [U]I' },
    { '<leader>de', function() require('dapui').eval(nil, { enter = true }) end, mode = { 'n', 'v' }, desc = '[D]ebug: [E]val expression' },
    { '<leader>dr', function() require('dap').repl.toggle() end, desc = '[D]ebug: Toggle [R]EPL' },

    -- Python-specific (pytest)
    { '<leader>dm', function() require('dap-python').test_method() end, desc = '[D]ebug: Test [M]ethod (python)' },
    { '<leader>dk', function() require('dap-python').test_class() end, desc = '[D]ebug: Test Class (python)' },
    { '<leader>ds', function() require('dap-python').debug_selection() end, mode = 'v', desc = '[D]ebug: [S]election (python)' },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      ensure_installed = { 'python' }, -- the mason package name for debugpy
      automatic_installation = true,
      -- Empty handlers: nvim-dap-python owns the python adapter/configurations below.
      handlers = {},
    }

    ---@diagnostic disable-next-line: missing-fields
    dapui.setup {
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      layouts = {
        {
          elements = {
            { id = 'scopes', size = 0.25 },
            { id = 'breakpoints', size = 0.25 },
            { id = 'stacks', size = 0.25 },
            { id = 'watches', size = 0.25 },
          },
          size = 40, -- columns
          position = 'left',
        },
        {
          -- dap-ui splits a tray's width evenly between its elements. The default
          -- bottom tray is {repl, console}, so the REPL only gets half the width.
          -- With console = 'internalConsole' there is no terminal for the console
          -- element to show, so drop it and let the REPL span the full width.
          elements = { { id = 'repl', size = 1.0 } },
          size = 12, -- rows
          position = 'bottom',
        },
      },
      ---@diagnostic disable-next-line: missing-fields
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    local breakpoint_icons = vim.g.have_nerd_font and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
      or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    for type, icon in pairs(breakpoint_icons) do
      local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
      vim.fn.sign_define('Dap' .. type, { text = icon, texthl = hl, numhl = hl })
    end

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- 'internalConsole' keeps debugpy from spawning a terminal buffer/window;
    -- the debugged program's output is routed into the dap REPL instead.
    -- Trade-off: the program cannot read stdin. Switch to 'integratedTerminal'
    -- if you ever need to type input into the program being debugged.
    require('dap-python').setup(debugpy_python(), { console = 'internalConsole' })
    require('dap-python').test_runner = 'pytest'

    -- nvim-dap spawns executable adapters with `detached = true`, which on Windows
    -- leaves the adapter with no console. debugpy then launches the debuggee, and
    -- Windows allocates a brand new console window for it (titled with python.exe).
    -- Running attached lets the adapter inherit Neovim's console, so no window pops up.
    if vim.fn.has 'win32' == 1 then
      local base = dap.adapters.python
      dap.adapters.python = function(cb, config, parent)
        base(function(adapter)
          if type(adapter) == 'table' and adapter.type == 'executable' then
            adapter.options = vim.tbl_extend('force', adapter.options or {}, { detached = false })
          end
          cb(adapter)
        end, config, parent)
      end
      dap.adapters.debugpy = dap.adapters.python
    end

    -- Debug the current file with the project's own interpreter (venv-aware),
    -- rather than the one debugpy was installed with.
    table.insert(dap.configurations.python, {
      type = 'python',
      request = 'launch',
      name = 'Launch file (project venv)',
      program = '${file}',
      console = 'internalConsole',
      cwd = '${workspaceFolder}',
      python = function()
        local venv = os.getenv 'VIRTUAL_ENV' or os.getenv 'CONDA_PREFIX'
        if venv then return venv .. (vim.fn.has 'win32' == 1 and '/Scripts/python.exe' or '/bin/python') end
        return vim.fn.exepath 'python'
      end,
    })
  end,
}

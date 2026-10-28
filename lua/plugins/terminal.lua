-- lua/plugins/terminal.lua
--
-- Floating and split terminals. The shell and the window sizes come from
-- config/settings.lua.
--
-- Keymaps
--   <C-/>       toggle the floaterm      <C-q>  kill it
--   <leader>uf  new floating terminal    <leader>ub / <leader>ur  split below / right
--   <leader>ul  last terminal            <leader>ui  first terminal
--   <leader>un  next terminal            <leader>up  previous terminal
--   <C-R>       (visual) send selection to the terminal
--   <leader>la  (visual) send the selection's file:lines to the terminal
--   <leader>le  (python) run the current file with `uv run --env-file .env`
--
-- Plain :term splits on <leader>bb and <leader>br live in config/keymaps.lua.

local s = require 'config.settings'

-- A visible floaterm with the cursor in it, created if none exists yet.
-- FloatermShow and FloatermNew both focus the window they open.
local function focus_term()
  local bufnr = vim.fn['floaterm#buflist#curr']()

  if bufnr > 0 then
    vim.cmd 'FloatermShow'
  else
    vim.cmd 'FloatermNew'
    bufnr = vim.fn['floaterm#buflist#curr']()
  end

  return bufnr
end

-- Tell a coding agent which code the next message is about: paste the
-- selection's file and line range at its prompt and leave the cursor there.
-- Nothing is submitted, so the user types the question after the reference.
local function send_code_ref()
  -- Forward slashes sidestep floaterm's backslash unescaping.
  local file = (vim.fn.expand '%:.'):gsub('\\', '/')
  if file == '' then
    vim.notify('Buffer has no file name', vim.log.levels.WARN)
    return
  end

  -- The '< and '> marks are only written on leaving visual mode, so read the
  -- live ends instead: 'v' is the anchor, '.' the cursor.
  local first, last = vim.fn.line 'v', vim.fn.line '.'
  if first > last then
    first, last = last, first
  end

  local fmt = s.floaterm.code_ref
  local ref = first == last and fmt.line:format(file, first) or fmt.range:format(file, first, last)

  -- Leave visual mode before changing window, else the selection follows.
  vim.cmd 'normal! \27'

  -- A third argument of 0 suppresses the newline floaterm#send would add.
  vim.fn['floaterm#terminal#send'](focus_term(), { ref .. ' ' }, 0)
end

---@module 'lazy'
---@type LazySpec
return {
  {
    'voldikss/vim-floaterm',
    lazy = false,
    keys = {
      { '<C-/>',      desc = 'Toggle floaterm' },
      { '<C-q>',      desc = 'Kill floaterm' },
      { '<leader>uf', ('<cmd>FloatermNew --wintype=float --width=%s<cr>'):format(s.floaterm.float_width), desc = '[U]I: new floating term' },
      { '<leader>ub', '<cmd>FloatermNew --wintype=split<cr>',                                             desc = '[U]I: new term below' },
      { '<leader>ur', '<cmd>FloatermNew --wintype=vsplit<cr>',                                            desc = '[U]I: new term right' },
      { '<leader>ul', '<cmd>FloatermLast<cr>',                                                            desc = '[U]I: [L]ast term' },
      { '<leader>ui', '<cmd>FloatermFirst<cr>',                                                           desc = '[U]I: F[i]rst term' },
      { '<leader>un', '<cmd>FloatermNext<cr>',                                                            desc = '[U]I: [N]ext term' },
      { '<leader>up', '<cmd>FloatermPrev<cr>',                                                            desc = '[U]I: [P]revious term' },
      { '<C-R>',      ':FloatermSend<cr>',                                                                mode = 'v',                      silent = true,                     desc = 'Send selection to terminal' },
      { '<leader>la', send_code_ref,                                                                      mode = 'x',                      desc = 'Send selection to [A]gent' },
    },
    init = function()
      -- Toggle and kill are set as g: variables rather than keys above
      -- because floaterm creates them itself across every mode.
      vim.g.floaterm_keymap_toggle = '<C-/>'
      vim.g.floaterm_keymap_kill = '<C-q>'
      vim.g.floaterm_shell = s.shell
      vim.g.floaterm_opener = 'edit'
      vim.g.floaterm_wintype = 'vsplit'
      vim.g.floaterm_width = s.floaterm.width

      -- Python files get <leader>le to run themselves in the terminal. The
      -- keymap is buffer-local so the key stays free elsewhere, and it lives
      -- here because it is useless without floaterm.
      vim.api.nvim_create_autocmd('FileType', {
        desc = 'Python: run current file with uv',
        group = vim.api.nvim_create_augroup('floaterm-python-run', { clear = true }),
        pattern = 'python',
        callback = function(args)
          vim.keymap.set('n', '<leader>le', function()
            -- ':.' is relative to Vim's cwd, matching the bare `.env` above.
            -- Forward slashes sidestep floaterm's backslash unescaping.
            local file = (vim.fn.expand '%:.'):gsub('\\', '/')

            -- FloatermToggle would hide an already open terminal, so only
            -- create one when none exists yet.
            if vim.fn['floaterm#buflist#curr']() > 0 then
              vim.cmd 'FloatermShow'
            else
              vim.cmd 'FloatermNew'
            end

            vim.cmd(('FloatermSend uv run --frozen --env-file .env %s'):format(file))
          end, { buffer = args.buf, desc = 'Run with Env' })
        end,
      })
    end,
  },
}

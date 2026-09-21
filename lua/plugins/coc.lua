-- lua/plugins/coc.lua
--
-- coc.nvim provides completion, diagnostics, formatting and goto-navigation.
-- It replaces the native LSP stack entirely — do not enable nvim-lspconfig,
-- blink.cmp or conform alongside it.
--
-- Server and formatter settings are NOT here: they live in coc-settings.json
-- at the config root, reachable with :CocConfig. Extensions are installed with
-- :CocInstall and listed by <leader>ce.
--
-- Keymaps
--   insert   <C-n>/<C-p> cycle, <CR>/<Tab> confirm, <C-Space> trigger
--   goto     gd gy gr, K hover, [g/]g diagnostics
--   <leader>a  code actions      <leader>r  refactor
--   <leader>l  rename / format   <leader>c  CocList pickers
--   textobj  if/af function, ic/ac class

local map = vim.keymap.set

local function pum_visible() return vim.fn['coc#pum#visible']() == 1 end

-- True when the cursor sits at the start of a line or after whitespace, where
-- a literal tab is wanted instead of a completion.
local function at_indent()
  local col = vim.fn.col '.' - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match '%s' ~= nil
end

local function setup_keymaps()
  -- Completion menu ------------------------------------------------------
  map('i', '<C-n>', function()
    if pum_visible() then return vim.fn['coc#pum#next'](1) end
    if at_indent() then return '\t' end
    return vim.fn['coc#refresh']()
  end, { silent = true, expr = true, desc = 'Coc: next completion' })

  map('i', '<C-p>', function()
    if pum_visible() then return vim.fn['coc#pum#prev'](1) end
    return '<C-h>'
  end, { silent = true, expr = true, desc = 'Coc: previous completion' })

  map('i', '<CR>', function()
    if pum_visible() then return vim.fn['coc#pum#confirm']() end
    -- <C-g>u breaks the undo sequence so a newline is its own undo step.
    return '<C-g>u<CR><c-r>=coc#on_enter()<CR>'
  end, { silent = true, expr = true, desc = 'Coc: confirm completion' })

  map('i', '<Tab>', function()
    if pum_visible() then return vim.fn['coc#pum#confirm']() end
    return '<C-g>u<Tab>'
  end, { silent = true, expr = true, desc = 'Coc: confirm completion' })

  map('i', '<C-Space>', 'coc#refresh()', { silent = true, expr = true, desc = 'Coc: trigger completion' })

  -- Navigation -----------------------------------------------------------
  map('n', '[g', '<Plug>(coc-diagnostic-prev)', { silent = true, nowait = true, desc = 'Coc: prev diagnostic' })
  map('n', ']g', '<Plug>(coc-diagnostic-next)', { silent = true, nowait = true, desc = 'Coc: next diagnostic' })
  map('n', 'gd', '<Plug>(coc-definition)', { silent = true, nowait = true, desc = '[G]oto [D]efinition' })
  map('n', 'gy', '<Plug>(coc-type-definition)', { silent = true, nowait = true, desc = '[G]oto t[y]pe definition' })
  map('n', 'gr', '<Plug>(coc-references)', { silent = true, nowait = true, desc = '[G]oto [R]eferences' })

  map('n', 'K', function()
    if vim.fn.CocAction('hasProvider', 'hover') then
      vim.fn.CocActionAsync 'doHover'
    else
      vim.api.nvim_feedkeys('K', 'in', false)
    end
  end, { silent = true, desc = 'Show documentation' })

  -- Actions --------------------------------------------------------------
  -- Every binding is a leaf; <leader>a and <leader>r are group prefixes.
  map({ 'n', 'x' }, '<leader>aa', '<Plug>(coc-codeaction-selected)', { desc = 'Code [A]ction (selection)' })
  map('n', '<leader>ac', '<Plug>(coc-codeaction-cursor)', { desc = 'Code [A]ction at [C]ursor' })
  map('n', '<leader>as', '<Plug>(coc-codeaction-source)', { desc = 'Code [A]ction [S]ource' })
  map('n', '<leader>af', '<Plug>(coc-fix-current)', { desc = 'Code [A]ction: quick[F]ix line' })
  map('n', '<leader>re', '<Plug>(coc-codeaction-refactor)', { silent = true, desc = '[Re]factor' })
  map({ 'n', 'x' }, '<leader>rr', '<Plug>(coc-codeaction-refactor-selected)', { silent = true, desc = '[R]efacto[r] selection' })

  map('n', '<leader>lr', '<Plug>(coc-rename)', { desc = 'LSP [R]ename' })
  map({ 'n', 'x' }, '<leader>lf', '<Plug>(coc-format-selected)', { desc = 'LSP [F]ormat selected' })
  map('n', '<leader>cl', '<Plug>(coc-codelens-action)', { desc = 'Coc: [C]ode [L]ens' })

  -- Text objects ---------------------------------------------------------
  map({ 'x', 'o' }, 'if', '<Plug>(coc-funcobj-i)', { desc = 'Inside function' })
  map({ 'x', 'o' }, 'af', '<Plug>(coc-funcobj-a)', { desc = 'Around function' })
  map({ 'x', 'o' }, 'ic', '<Plug>(coc-classobj-i)', { desc = 'Inside class' })
  map({ 'x', 'o' }, 'ac', '<Plug>(coc-classobj-a)', { desc = 'Around class' })
  map({ 'n', 'x' }, '<C-s>', '<Plug>(coc-range-select)', { silent = true, desc = 'Coc: expand selection' })

  -- Scroll a hover or signature float instead of the buffer.
  local function scroll(forward)
    return function()
      if vim.fn['coc#float#has_scroll']() == 1 then return vim.fn['coc#float#scroll'](forward) end
      return forward == 1 and '<C-f>' or '<C-b>'
    end
  end

  map({ 'n', 'i', 'v' }, '<C-f>', scroll(1), { silent = true, nowait = true, expr = true, desc = 'Scroll float down' })
  map({ 'n', 'i', 'v' }, '<C-b>', scroll(0), { silent = true, nowait = true, expr = true, desc = 'Scroll float up' })

  -- CocList pickers ------------------------------------------------------
  local lists = {
    { 'ca', 'diagnostics', '[A]ll diagnostics' },
    { 'ce', 'extensions', '[E]xtensions' },
    { 'cc', 'commands', '[C]ommands' },
    { 'co', 'outline', '[O]utline' },
    { 'cs', '-I symbols', '[S]ymbols' },
    { 'y', '-A --normal yank', 'Yank history' },
  }
  for _, list in ipairs(lists) do
    local key, arg, desc = list[1], list[2], list[3]
    map('n', '<leader>' .. key, (':<C-u>CocList %s<cr>'):format(arg), { silent = true, nowait = true, desc = 'Coc: ' .. desc })
  end

  map('n', '<leader>cj', ':<C-u>CocNext<CR>', { silent = true, nowait = true, desc = 'Coc: next item' })
  map('n', '<leader>ck', ':<C-u>CocPrev<CR>', { silent = true, nowait = true, desc = 'Coc: prev item' })
  map('n', '<leader>cp', ':<C-u>CocListResume<CR>', { silent = true, nowait = true, desc = 'Coc: resume list' })
end

local function setup_commands()
  local cmd = vim.api.nvim_create_user_command
  cmd('Format', function() vim.fn.CocActionAsync 'format' end, { desc = 'Format the buffer via coc' })
  cmd('Fold', function(o) vim.fn.CocAction('fold', o.fargs[1]) end, { nargs = '?', desc = 'Fold by kind via coc' })
  cmd('OR', function() vim.fn.CocActionAsync('runCommand', 'editor.action.organizeImport') end, { desc = 'Organize imports via coc' })
end

---@module 'lazy'
---@type LazySpec
return {
  'neoclide/coc.nvim',
  branch = 'release',
  init = function()
    -- Extensions listed here are installed on first launch. Anything added
    -- interactively with :CocInstall is not tracked — put it here to keep the
    -- config reproducible.
    -- vim.g.coc_global_extensions = { 'coc-pyright', 'coc-lua', 'coc-json' }
  end,
  config = function()
    setup_keymaps()
    setup_commands()

    -- Highlight the symbol under the cursor and its references after a pause.
    vim.api.nvim_create_autocmd('CursorHold', {
      desc = 'Coc: highlight symbol under cursor',
      group = vim.api.nvim_create_augroup('config-coc-highlight', { clear = true }),
      callback = function() vim.fn.CocActionAsync 'highlight' end,
    })
  end,
}

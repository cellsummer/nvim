# nvim

Personal Neovim configuration. Descended from
[kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), with
[coc.nvim](https://github.com/neoclide/coc.nvim) instead of the native LSP
stack and [snacks.nvim](https://github.com/folke/snacks.nvim) instead of
telescope.

The full tour lives in the editor: **`:help nvim-config`**.

## Where to change things

Almost everything you will want to adjust is in one file, `:Config` away:

| Change | File |
| --- | --- |
| Colorscheme, indent, scrolloff, shell, paths, treesitter parsers | `lua/config/settings.lua` |
| Any other vim option | `lua/config/options.lua` |
| An editor keymap | `lua/config/keymaps.lua` |
| An autocommand | `lua/config/autocmds.lua` |
| A plugin, or its keymaps | `lua/plugins/<area>.lua` |
| A language server, formatter or linter | `coc-settings.json` (`:CocConfig`) |

## Layout

```
init.lua              bootstrap only
lua/config/           settings, options, keymaps, autocmds, health
lua/plugins/          one file per area; each spec sits with its keymaps
doc/nvim-config.txt   :help nvim-config
coc-settings.json     coc servers and formatters
_vimrc                the pre-Neovim config, kept for reference
```

## Finding your way around

| | |
| --- | --- |
| `<leader>` | key hint popup, grouped |
| `<leader>sk` | fuzzy search every keymap and its description |
| `<leader>fn` | jump to any file in this config |
| `:Config` | open `lua/config/settings.lua` |
| `:checkhealth config` | what the config is doing right now, and what is missing |
| `:Lazy` | plugin status and startup profiling |

The keymap list is generated from live mappings, so it cannot go stale. Give
every new binding a `desc`.

## Requirements

`git`, `ripgrep`, `node` (coc will not start without it), `unzip`, a C
compiler, and a Nerd Font. `python` for the debugger. `:checkhealth config`
tells you which are missing and what each one is for.

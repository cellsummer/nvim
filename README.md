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

## Neovide as a terminal

Neovide can replace a terminal emulator: open it with no file and it starts on
a shell, tabs act as a multiplexer's windows, and splits act as its panes.
Turn it off with `terminal_ui.enabled` in `lua/config/settings.lua`.

Terminals come from floaterm rather than plain `:term`, because floaterm puts a
`floaterm` command and a `$GIT_EDITOR` on the shell's `PATH` that open files in
the running Neovim. So `git commit` and `floaterm notes.md` work from the
shell without starting a second Neovim inside the first, and they work the same
on macOS and Windows with nothing added to `~/.zshrc` or the PowerShell
profile.

A shell fills its tab, beside a second window squeezed to no width. That window
has to exist: floaterm opens a file by closing the shell's window to make room,
and Neovim refuses that for the last window in a tab. It is where `git commit`
and `floaterm <file>` land, and it costs one column. `<C-/>` then swaps
full-screen between the shell and whatever is open, both keeping their size.

### Keybinds added

| | |
| --- | --- |
| `<M-CR>` | new shell in its own tab |
| `<M-Space>` | shell pane below |
| `<M-\>` | shell pane right |
| `<M-h>` / `<M-l>` | previous / next tab |
| `<M-q>` | close the shell under the cursor, or the tab |
| `<leader>un` / `<leader>up` | next / previous terminal in the ring |
| `<C-=>` `<C-->` `<C-0>` | zoom in, out, reset — now answer from the shell too |

`<C-/>` and `<C-q>` keep toggling and killing the terminal as before.

`<Esc><Esc>` and `<C-;>` already left terminal mode; they now also turn the
line numbers back on, so scrollback reads like a file. Entering the shell again
hides them.

These Meta chords are forwarded to the shell's line editor as raw escape
sequences, because Neovide has to claim Option before any `<M-...>` key
arrives at all. They are skipped when the shell is `cmd`:

| | |
| --- | --- |
| `<M-b>` / `<M-Left>` | back one word |
| `<M-f>` / `<M-Right>` | forward one word |
| `<M-d>` | delete word forward |
| `<M-BS>` | delete word back |
| `<M-.>` | insert last argument |

`<M-h>` and `<M-l>` are the exception: they drive tabs, so the shell loses them.
`<M-j>` and `<M-k>` still move lines.

### Setting it up

The font and window frame live in Neovide's own `config.toml`, not in this
repo — `~/.config/neovide/config.toml` on macOS,
`~/AppData/Roaming/neovide/config.toml` on Windows:

```toml
[font]
normal = ["YourNerdFont"]
size = 14.0
```

On macOS, `neovide_input_macos_option_key_is_meta` is set to `only_left`, so
the right Option key still types accented characters. Without it no `<M-...>`
chord reaches Neovim, and the multiplexer keys fail silently.
`:checkhealth config` reports this.

On Windows the shell defaults to `cmd`. Change `shell` in
`lua/config/settings.lua` to `pwsh` for a line editor that understands the
Meta chords above.

Launched from Spotlight or the Start menu, Neovide does not inherit a login
shell, so check `:echo $PATH` matches your shell's before blaming anything
else.

## Requirements

`git`, `ripgrep`, `node` (coc will not start without it), `unzip`, a C
compiler, and a Nerd Font. `python` for the debugger. `:checkhealth config`
tells you which are missing and what each one is for.

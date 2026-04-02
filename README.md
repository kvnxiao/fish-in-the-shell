# fish-in-the-shell (fits)

A [fish shell](https://fishshell.com/) plugin that replaces the built-in tab completion with an interactive fuzzy completion menu powered by [skim](https://github.com/lotabout/skim) or [fzf](https://github.com/junegunn/fzf). Type a command, press Tab, and get a searchable, previewable list of completions — files, directories, commands, options, processes, and more.

## Features

- **Drop-in Tab replacement** — binds to Tab out of the box; all your existing fish completions still work
- **Smart previews** — contextual previews for files (`bat`), directories (`eza`/`lsd`/`ls`), man pages, fish functions, command options, and processes
- **Completion grouping** — automatically detects whether you're completing files, directories, options, or processes and adjusts behavior accordingly
- **Multi-select** — select multiple items with configurable keybindings
- **Debounced previews** — avoids spawning heavy preview commands while scrolling quickly
- **Works with skim and fzf** — auto-detects whichever is installed (prefers `sk`)
- **Enhanced tools integration** — uses `bat`, `eza`/`lsd`, `fd`, and `procs` when available, falls back to standard tools

## Requirements

- [fish](https://fishshell.com/) 3.0+
- [skim](https://github.com/lotabout/skim) **or** [fzf](https://github.com/junegunn/fzf)

### Optional (recommended)

| Tool | Used for |
|------|----------|
| [bat](https://github.com/sharkdp/bat) | Syntax-highlighted file previews |
| [eza](https://github.com/eza-community/eza) or [lsd](https://github.com/lsd-rs/lsd) | Rich directory listings |
| [fd](https://github.com/sharkdp/fd) | Fast file/directory searching |
| [procs](https://github.com/dalance/procs) | Enhanced process previews |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Faster option preview lookups in man pages |

## Installation

### [Fisher](https://github.com/jorgebucaran/fisher) (recommended)

```fish
fisher install kvnxiao/fish-in-the-shell
```

### Manual

Copy the `functions/` and `conf.d/` directories into your fish config:

```fish
cp functions/*.fish ~/.config/fish/functions/
cp conf.d/*.fish ~/.config/fish/conf.d/
```

## Configuration

All settings are stored as fish [universal variables](https://fishshell.com/docs/current/language.html#universal-variables) and persist across sessions. Change them with `set -U`:

| Variable | Default | Description |
|----------|---------|-------------|
| `fits_fuzzy_cmd` | auto (`sk` > `fzf`) | Fuzzy menu command |
| `fits_keybinding` | `\t` (Tab) | Key to trigger fits |
| `fits_height` | `40%` | Menu height (`full` for fullscreen) |
| `fits_preview_window` | `right,50%,border-left,<80(up,40%,border-bottom)` | fzf preview window layout |
| `fits_sk_preview_window` | `right:50%` | skim preview window layout |
| `fits_fzf_opts` | *(empty)* | Extra flags passed to fzf |
| `fits_sk_opts` | *(empty)* | Extra flags passed to skim |
| `fits_fzf_binds` | `tab:down` `shift-tab:up` `shift-down:select+down` `shift-up:select+up` `ctrl-space:toggle` `ctrl-d:deselect-all` | fzf keybindings |
| `fits_builtin_search` | `false` | Use fish builtins instead of external grep/sed (useful on Cygwin/MSYS2) |
| `fits_bat_opts` | *(empty)* | Extra flags passed to `bat` |
| `fits_eza_opts` | *(empty)* | Extra flags passed to `eza` |
| `fits_lsd_opts` | *(empty)* | Extra flags passed to `lsd` |
| `fits_fd_opts` | *(empty)* | Extra flags passed to `fd` |

### Examples

```fish
# Use fzf even if skim is installed
set -U fits_fuzzy_cmd fzf

# Full-height menu
set -U fits_height full

# Pass extra options to bat
set -U fits_bat_opts --theme=Dracula

# Pass extra options to fd
set -U fits_fd_opts --no-ignore
```

## How it works

1. You type a command and press Tab
2. fits collects completions from fish's built-in `complete` system
3. Completions are categorized (files, directories, options, processes, or general)
4. The fuzzy completion menu opens with contextual previews:
   - **Files** → syntax-highlighted content via `bat`
   - **Directories** → rich listing via `eza`/`lsd`
   - **Commands** → man page
   - **Fish functions** → function source
   - **Options** → relevant man page section
   - **Processes** → process tree via `procs`
5. Select one or more items and they're inserted into your command line

## License

[MIT](LICENSE)

# fits - fzf-powered inline tab completion for fish
# https://github.com/kvnxiao/fish-in-the-shell

# Only load in interactive sessions
status is-interactive; or return

# Resolve fuzzy finder: user override > sk > fzf
if set -qU fits_fuzzy_cmd
    if not type -q $fits_fuzzy_cmd
        return
    end
else if type -q sk
    set -U fits_fuzzy_cmd sk
else if type -q fzf
    set -U fits_fuzzy_cmd fzf
else
    return
end

# Set defaults for universal variables (only if not already set)
set -qU fits_keybinding; or set -U fits_keybinding \t
set -qU fits_height; or set -U fits_height '40%'
set -qU fits_preview_window; or set -U fits_preview_window 'right,50%,border-left,<80(up,40%,border-bottom)'
set -qU fits_sk_preview_window; or set -U fits_sk_preview_window 'right:50%'
set -qU fits_fzf_opts; or set -U fits_fzf_opts
set -qU fits_sk_opts; or set -U fits_sk_opts
set -qU fits_fzf_binds; or set -U fits_fzf_binds 'tab:down' 'shift-tab:up' 'shift-down:select+down' 'shift-up:select+up' 'ctrl-space:toggle' 'ctrl-d:deselect-all'
set -qU fits_builtin_search; or set -U fits_builtin_search false
set -qU fits_bat_opts; or set -U fits_bat_opts
set -qU fits_eza_opts; or set -U fits_eza_opts
set -qU fits_lsd_opts; or set -U fits_lsd_opts
set -qU fits_fd_opts; or set -U fits_fd_opts

# Bind Tab to fits in default and insert modes
bind $fits_keybinding _fits
bind --mode insert $fits_keybinding _fits 2>/dev/null

# Fisher uninstall hook
function _fits_uninstall --on-event fits_uninstall
    bind --erase $fits_keybinding
    bind --erase --mode insert $fits_keybinding 2>/dev/null
    set -e fits_fuzzy_cmd
    set -e fits_keybinding
    set -e fits_height
    set -e fits_preview_window
    set -e fits_sk_preview_window
    set -e fits_fzf_opts
    set -e fits_sk_opts
    set -e fits_fzf_binds
    set -e fits_builtin_search
    set -e fits_bat_opts
    set -e fits_eza_opts
    set -e fits_lsd_opts
    set -e fits_fd_opts
end

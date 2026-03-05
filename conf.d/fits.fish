# fits - fzf-powered inline tab completion for fish
# https://github.com/kvnxiao/fish-in-the-shell

# Only load in interactive sessions
status is-interactive; or return

# Guard: fzf is required
if not type -q fzf
    return
end

# Set defaults for universal variables (only if not already set)
set -qU fits_keybinding; or set -U fits_keybinding \t
set -qU fits_height; or set -U fits_height '40%'
set -qU fits_fzf_opts; or set -U fits_fzf_opts
set -qU fits_fzf_binds; or set -U fits_fzf_binds 'tab:down' 'shift-tab:up' 'shift-down:select+down' 'shift-up:select+up' 'ctrl-space:toggle' 'ctrl-d:deselect-all'
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
    set -e fits_keybinding
    set -e fits_height
    set -e fits_fzf_opts
    set -e fits_fzf_binds
    set -e fits_bat_opts
    set -e fits_eza_opts
    set -e fits_lsd_opts
    set -e fits_fd_opts
end

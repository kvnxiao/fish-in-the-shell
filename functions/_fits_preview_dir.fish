function _fits_preview_dir --description "Preview a directory using lsd, eza, or ls"
    set -l dirpath $argv[1]

    if type -q lsd
        lsd --color=always --icon=always -la $fits_lsd_opts -- "$dirpath" 2>/dev/null
    else if type -q eza
        eza --color=always --icons --long --all $fits_eza_opts -- "$dirpath" 2>/dev/null
    else
        ls -la -- "$dirpath" 2>/dev/null
    end
end

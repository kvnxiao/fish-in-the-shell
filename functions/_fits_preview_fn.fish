function _fits_preview_fn --description "Preview a fish function definition"
    set -l fn $argv[1]

    if type -q bat
        type -- "$fn" 2>/dev/null | bat --color=always --style=plain --language=fish 2>/dev/null
    else
        type -- "$fn" 2>/dev/null
    end
end

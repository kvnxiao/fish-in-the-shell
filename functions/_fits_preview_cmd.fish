function _fits_preview_cmd --description "Preview a command via man page"
    set -l cmd $argv[1]

    if type -q man
        if type -q bat
            man "$cmd" 2>/dev/null | bat --color=always --style=plain --language=man 2>/dev/null
        else
            man "$cmd" 2>/dev/null | col -bx 2>/dev/null | head -100
        end
    else
        echo "Command: $cmd"
        type -a -- "$cmd" 2>/dev/null
    end
end

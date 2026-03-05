function _fits_source_paths --description "List paths for completion using fd or find"
    set -l type_flag $argv[1]
    set -l dir (_fits_path_to_complete)
    test -z "$dir"; and set dir .

    if type -q fd
        set -l fd_args --color=always --hidden --follow --exclude=.git
        test -n "$type_flag"; and set -a fd_args --type $type_flag
        fd $fd_args $fits_fd_opts -- . "$dir" 2>/dev/null
    else
        set -l find_args "$dir" -mindepth 1 -not -path '*/.git/*'
        test -n "$type_flag"; and set -a find_args -type $type_flag
        find $find_args 2>/dev/null | sort
    end
end

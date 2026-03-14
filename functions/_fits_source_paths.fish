function _fits_source_paths --description "List paths for completion using fd or find"
    set -l type_flag $argv[1]
    set -l dir (_fits_path_to_complete)
    test -z "$dir"; and set dir .

    # Extract the partial filename (last component) for filtering
    set -l expanded (_fits_expand_tilde "$fits_token")
    set -l partial (string replace -r '.*/' '' -- "$expanded")

    if type -q fd
        set -l fd_args --color=always --hidden --follow --exclude '.git/**'
        test -n "$type_flag"; and set -a fd_args --type $type_flag
        # Use partial as a prefix pattern so fd skips non-matching subtrees
        set -l pattern '.'
        if test -n "$partial"
            set pattern "^"(string escape --style=regex -- "$partial")
        end
        fd $fd_args $fits_fd_opts -- "$pattern" "$dir" 2>/dev/null
    else
        set -l find_args "$dir" -mindepth 1 -not -path '*/.git/*'
        test -n "$type_flag"; and set -a find_args -type $type_flag
        if test -n "$partial"
            set -a find_args -name "$partial*"
        end
        find $find_args 2>/dev/null | sort
    end
end

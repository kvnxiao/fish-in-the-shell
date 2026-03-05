function _fits_preview_opt --description "Preview an option by extracting its man page section"
    set -l option $argv[1]
    set -l desc $argv[2]

    # Get the command name (first word of commandline)
    set -l cmd (string split -m 1 ' ' -- "$fits_commandline")[1]

    if test -z "$cmd"
        echo "$desc"
        return
    end

    # Cache man page output to avoid re-fetching on every fzf cursor move
    set -l cache_file "/tmp/fits_man_$cmd"
    if not test -f "$cache_file"
        man "$cmd" 2>/dev/null | col -bx 2>/dev/null >"$cache_file"
    end

    set -l mantext (cat "$cache_file" 2>/dev/null)
    if test -z "$mantext"
        rm -f "$cache_file" 2>/dev/null
        echo "$desc"
        return
    end

    # Escape option for regex safety (e.g. --foo.bar → --foo\.bar)
    set -l escaped_option (string escape --style=regex -- "$option")

    # Build a pattern to match the option in the man page
    set -l pattern
    if string match -qr '^--' -- "$option"
        set pattern "^\\s*$escaped_option"
    else if string match -qr '^-' -- "$option"
        set pattern "^\\s*$escaped_option"'[,\s]'
    else
        echo "$desc"
        return
    end

    # Pick whichever grep variant is available
    set -l grep_cmd
    if type -q rg
        set grep_cmd rg
    else if type -q grep
        set grep_cmd grep
    end

    # Extract lines around the option match
    if test -n "$grep_cmd"
        set -l match_output (echo "$mantext" | $grep_cmd -n "$pattern" 2>/dev/null | head -1)
        if test -n "$match_output"
            set -l line_num (string split -m 1 ':' -- "$match_output")[1]
            echo "$mantext" | sed -n "$line_num,+20p" 2>/dev/null
            return
        end
    end

    # Fallback to fish completion description
    echo "$desc"
end

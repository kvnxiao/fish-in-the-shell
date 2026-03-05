function _fits_completion_group --description "Categorize completions into a group"
    set -l complist_file $argv[1]
    set -l token $argv[2]

    if not test -f "$complist_file"
        return
    end

    # Extract just the completion names (first column)
    set -l names (string replace -r '\t.*' '' <"$complist_file")
    if test -z "$names"
        return
    end

    # Check if current token starts with a dash (option completion)
    if string match -qr '^-' -- "$token"
        echo options
        return
    end

    # Classify all completions in a single pass
    set -l all_dirs true
    set -l all_files true
    set -l all_numeric true

    for name in $names
        set -l resolved (_fits_expand_tilde "$name")
        test -d "$resolved"; or set all_dirs false
        test -e "$resolved"; or set all_files false
        string match -qr '^\d+$' -- "$name"; or set all_numeric false

        # Short-circuit: if nothing is "all" anymore, stop early
        if test "$all_dirs" = false -a "$all_files" = false -a "$all_numeric" = false
            return
        end
    end

    if test "$all_dirs" = true
        echo directories
    else if test "$all_files" = true
        echo files
    else if test "$all_numeric" = true
        echo processes
    end
end

function _fits_preview_debounce --description "Debounced preview wrapper to avoid spawning heavy commands while scrolling"
    set -l item $argv[1]
    set -l tmpdir "$TMPDIR"
    test -z "$tmpdir"; and set tmpdir "$TEMP"
    test -z "$tmpdir"; and set tmpdir /tmp
    set -l parent_pid (string replace -r '.*fits_complist_' '' -- "$fits_complist")
    set -l debounce_file "$tmpdir/fits_debounce_$parent_pid"

    # Stamp this item as the latest request
    printf '%s' "$item" >"$debounce_file"

    # Wait briefly (builtin read -t, no process spawn)
    read -t 0.05 -l _unused </dev/null

    # Only run the preview if no newer request has overwritten the file
    set -l latest
    read -z latest <"$debounce_file"
    if test "$latest" = "$item"
        _fits_preview "$item"
    end
end

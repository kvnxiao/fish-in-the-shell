function _fits --description "fzf-powered inline tab completion for fish"
    # Capture commandline state in key-binding context (commandline builtin
    # is only reliable here, not inside command substitutions)
    set -gx fits_commandline (commandline --cut-at-cursor)
    set -gx fits_token (commandline --current-token --cut-at-cursor)

    # Bail if commandline is empty
    if test -z (string trim -- "$fits_commandline")
        _fits_cleanup
        return
    end

    # Bail if completing arguments for an unrecognized command
    # Use --current-process to correctly handle pipes, ;, &&, ||
    set -l current_process (commandline --current-process --cut-at-cursor)
    if string match -qr '\S\s' -- "$current_process"
        set -l base_cmd (string split -m 1 ' ' -- (string trim -l -- "$current_process"))[1]
        set base_cmd (_fits_expand_tilde "$base_cmd")
        if not type -q -- "$base_cmd" 2>/dev/null; and not test -x "$base_cmd" 2>/dev/null
            _fits_cleanup
            return
        end
    end

    # Generate completions to a temp file (stable path, no rm needed)
    set -l _fits_tmpdir "$TMPDIR"
    test -z "$_fits_tmpdir"; and set _fits_tmpdir "$TEMP"
    test -z "$_fits_tmpdir"; and set _fits_tmpdir /tmp
    set -gx fits_complist "$_fits_tmpdir/fits_complist_$fish_pid"
    complete -C "$fits_commandline" >"$fits_complist" 2>/dev/null

    # Determine completion group (pass token explicitly)
    set -gx fits_group (_fits_completion_group "$fits_complist" "$fits_token")

    # Build --bind flag from fits_fzf_binds list
    set -l fzf_bind_opts
    if set -q fits_fzf_binds[1]
        set fzf_bind_opts --bind (string join ',' -- $fits_fzf_binds)
    end

    # Fuzzy finder options (sk vs fzf)
    set -l height_opts
    if test "$fits_height" != full
        set height_opts --height "$fits_height"
    end

    set -l is_sk (string match -q 'sk' -- $fits_fuzzy_cmd; and echo 1; or echo 0)
    set -l preview_window_val
    set -l extra_opts
    set -l scrollbar_opts
    if test "$is_sk" = 1
        set preview_window_val "$fits_sk_preview_window"
        set extra_opts $fits_sk_opts
    else
        set preview_window_val "$fits_preview_window"
        set extra_opts $fits_fzf_opts
        set scrollbar_opts --scrollbar '█'
    end

    set -l fzf_opts \
        $height_opts \
        --border rounded \
        --layout=reverse \
        $scrollbar_opts \
        --exact \
        --tiebreak=length \
        --ansi \
        --multi \
        --select-1 \
        --exit-0 \
        --delimiter='\t' \
        --with-nth=1..2 \
        --preview-window "$preview_window_val" \
        --preview "fish -c '_fits_preview_debounce {1}'" \
        $fzf_bind_opts \
        $extra_opts

    # Compute prefix for matching and fzf query
    set -l query_opts
    set -l match_prefix
    if test -n "$fits_token"
        set -l expanded (_fits_expand_tilde "$fits_token")
        switch "$fits_group"
            case directories files
                set -l dir (_fits_path_to_complete)
                if test -z "$dir"
                    set match_prefix "./$expanded"
                else
                    set match_prefix "$expanded"
                end
            case '*'
                set match_prefix "$fits_token"
        end
        if test -n "$match_prefix"
            set query_opts --query "^$match_prefix"
        end
    end

    # Collect candidates
    set -l candidates
    switch "$fits_group"
        case directories
            set candidates (_fits_source_paths d)
        case files
            set candidates (_fits_source_paths)
        case processes
            set candidates (ps -ax -o pid=,command= 2>/dev/null)
        case '*'
            while read -l line
                set -a candidates "$line"
            end <"$fits_complist"
    end

    # Short-circuit: skip fzf when exactly one candidate matches
    set -l result
    if test (count $candidates) -eq 0
        commandline --function repaint
        _fits_cleanup
        return
    else if test (count $candidates) -eq 1
        set result $candidates[1]
    else if test -n "$match_prefix" -a (count $candidates) -gt 1
        set -l filtered
        for c in $candidates
            set -l plain (string replace -ra '\e\[[0-9;]*m' '' -- "$c")
            set plain (string replace -r '\t.*' '' -- "$plain")
            if string match -q "$match_prefix*" -- "$plain"
                set -a filtered "$c"
            end
        end
        if test (count $filtered) -eq 1
            set result $filtered[1]
        else if test (count $filtered) -eq 0
            commandline --function repaint
            _fits_cleanup
            return
        end
    end

    # Fall back to fuzzy finder for interactive selection
    set -l fzf_status 0
    if not set -q result[1]
        set -l tmpinput "$_fits_tmpdir/fits_input_$fish_pid"
        printf '%s\n' $candidates >"$tmpinput"
        # Move skim below the current input line
        printf '\n' >/dev/tty
        set result ($fits_fuzzy_cmd $fzf_opts $query_opts <"$tmpinput")
        set fzf_status $status
    end

    # If fzf was cancelled or no result, repaint and bail
    if test $fzf_status -ne 0 -o -z "$result"
        commandline --function repaint
        _fits_cleanup
        return
    end

    # Strip ANSI codes and tab-separated descriptions from results
    set result (string replace -ra '\e\[[0-9;]*m' '' -- $result)
    set result (string replace -r '\t.*' '' -- $result)

    # Process the selected results
    set -l escaped
    for item in $result
        if string match -qr '^~' -- "$item"
            set -a escaped '~'(string escape --no-quoted -- (string sub -s 2 -- "$item"))
        else if string match -qr '^\$' -- "$item"
            set -a escaped '$'(string escape --no-quoted -- (string sub -s 2 -- "$item"))
        else
            set -a escaped (string escape --no-quoted -- "$item")
        end
    end

    # Replace the current token
    commandline --replace --current-token -- (string join ' ' -- $escaped)

    # Add trailing space unless it's a directory or multi-select
    if test (count $result) -eq 1
        set -l resolved (_fits_expand_tilde "$result[1]")
        if not test -d "$resolved"
            commandline --insert -- ' '
        end
    end

    commandline --function repaint
    _fits_cleanup
end

function _fits_cleanup --description "Clean up exported fits variables"
    set -e fits_commandline
    set -e fits_complist
    set -e fits_group
    set -e fits_token
end

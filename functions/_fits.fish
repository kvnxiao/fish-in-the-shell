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

    # Generate completions to a temp file
    set -gx fits_complist (mktemp)
    complete -C "$fits_commandline" >"$fits_complist" 2>/dev/null

    # Determine completion group (pass token explicitly)
    set -gx fits_group (_fits_completion_group "$fits_complist" "$fits_token")

    # Build --bind flag from fits_fzf_binds list
    set -l fzf_bind_opts
    if set -q fits_fzf_binds[1]
        set fzf_bind_opts --bind (string join ',' -- $fits_fzf_binds)
    end

    # fzf options
    set -l fzf_opts \
        --height "$fits_height" \
        --border rounded \
        --layout=reverse \
        --exact \
        --tiebreak=length \
        --ansi \
        --multi \
        --select-1 \
        --exit-0 \
        --delimiter='\t' \
        --with-nth=1..2 \
        --preview "fish -c '_fits_preview {1}'" \
        $fzf_bind_opts \
        $fits_fzf_opts

    # Source completions and pipe through fzf
    set -l result
    switch "$fits_group"
        case directories
            set result (_fits_source_paths d | fzf $fzf_opts)
        case files
            set result (_fits_source_paths | fzf $fzf_opts)
        case processes
            set result (ps -ax -o pid=,command= 2>/dev/null | fzf $fzf_opts)
        case '*'
            set result (fzf $fzf_opts <"$fits_complist")
    end
    set -l fzf_status $status

    # Clean up temp file
    rm -f "$fits_complist" 2>/dev/null

    # If fzf was cancelled, repaint and bail
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
            set -a escaped (string sub -s 2 -- "$item" | string escape --no-quoted | string replace -r '^' '~')
        else if string match -qr '^\$' -- "$item"
            set -a escaped (string sub -s 2 -- "$item" | string escape --no-quoted | string replace -r '^' '$')
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

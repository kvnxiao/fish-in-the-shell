function _fits_preview --description "Preview dispatcher for fzf"
    set -l fits_candidate (_fits_expand_tilde "$argv[1]")
    set -l fits_desc ""

    # Look up the description for this candidate from the complist
    if test -n "$fits_complist" -a -f "$fits_complist"
        set -l target "$argv[1]"\t
        while read -l line
            if string match -q -- "$target*" "$line"
                set fits_desc (string split -m 1 \t -- "$line")[2]
                break
            end
        end <"$fits_complist"
    end

    # Determine if we're in command position (first token, or second token
    # after a command-wrapper like sudo/env/doas)
    set -l in_command_position
    if not string match -qr '\S\s' -- "$fits_commandline"
        set in_command_position true
    else
        set -l base_cmd (string split -m 1 ' ' -- (string trim -l -- "$fits_commandline"))[1]
        switch "$base_cmd"
            case sudo doas env command builtin exec nohup nice time
                set in_command_position true
        end
    end

    # Dispatch based on group and file tests
    if test "$fits_group" = options
        _fits_preview_opt "$fits_candidate" "$fits_desc"
    else if test -f "$fits_candidate"
        _fits_preview_file "$fits_candidate"
    else if test -d "$fits_candidate"
        _fits_preview_dir "$fits_candidate"
    else if test "$fits_group" = processes
        _fits_preview_process "$fits_candidate"
    else if test -n "$in_command_position"; and type -q -- "$fits_candidate" 2>/dev/null
        if functions -q -- "$fits_candidate"
            _fits_preview_fn "$fits_candidate"
        else
            _fits_preview_cmd "$fits_candidate"
        end
    else if test -n "$fits_desc"
        echo "$fits_desc"
    end
end

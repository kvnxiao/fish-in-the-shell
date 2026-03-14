function _fits_expand_tilde --description "Expand ~ and \$VAR in a token"
    set -l s (string replace -r '^~' "$HOME" -- $argv[1])
    while set -l m (string match -r '^(.*?)\$(\w+)(.*)$' -- $s)
        set -l varname $m[3]
        if set -q $varname
            set s "$m[2]$$varname$m[4]"
        else
            break
        end
    end
    echo $s
end

function _fits_expand_tilde --description "Expand ~ to \$HOME in a path"
    string replace -r '^~' "$HOME" -- $argv[1]
end

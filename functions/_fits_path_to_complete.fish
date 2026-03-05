function _fits_path_to_complete --description "Extract directory prefix from current token"
    set -l expanded (_fits_expand_tilde "$fits_token")

    # If the token ends with /, the whole token is the path prefix
    if string match -qr '/$' -- "$expanded"
        echo "$expanded"
        return
    end

    # Strip the last path component to get the directory prefix
    set -l dir (string replace -r '/[^/]*$' '/' -- "$expanded")

    # Only return if the replacement produced a trailing slash
    # (bare tokens without / would be returned unchanged otherwise)
    if string match -qr '/$' -- "$dir"
        echo "$dir"
    end
end

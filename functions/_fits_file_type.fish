function _fits_file_type --description "Detect file type category via MIME"
    set -l filepath $argv[1]

    if not test -f "$filepath"
        echo unknown
        return
    end

    set -l mime (file --brief --mime-type -- "$filepath" 2>/dev/null)

    switch "$mime"
        case 'text/*' 'application/json' 'application/xml' 'application/javascript' \
             'application/x-shellscript' 'application/x-perl' 'application/x-ruby' \
             'application/x-python' 'application/toml' 'application/yaml'
            echo text
        case 'image/*'
            echo image
        case 'application/pdf'
            echo pdf
        case 'application/gzip' 'application/x-tar' 'application/zip' \
             'application/x-bzip2' 'application/x-xz' 'application/x-7z-compressed' \
             'application/x-rar' 'application/zstd' 'application/x-compress'
            echo archive
        case '*'
            echo binary
    end
end

function _fits_preview_file --description "Preview a file using bat or cat"
    set -l filepath $argv[1]
    set -l filetype (_fits_file_type "$filepath")

    switch "$filetype"
        case text
            if type -q bat
                bat --color=always --style=numbers --line-range=:500 $fits_bat_opts -- "$filepath" 2>/dev/null
            else if test "$fits_builtin_search" = true
                set -l n 500
                while test $n -gt 0; and read -l line
                    echo "$line"
                    set n (math $n - 1)
                end <"$filepath"
            else
                cat -- "$filepath" 2>/dev/null | head -500
            end
        case image
            echo "Image: $filepath"
            file -- "$filepath" 2>/dev/null
        case pdf
            echo "PDF: $filepath"
            file -- "$filepath" 2>/dev/null
        case archive
            switch "$filepath"
                case '*.tar.gz' '*.tgz'
                    tar -tzf "$filepath" 2>/dev/null | head -100
                case '*.tar.bz2'
                    tar -tjf "$filepath" 2>/dev/null | head -100
                case '*.tar.xz'
                    tar -tJf "$filepath" 2>/dev/null | head -100
                case '*.tar'
                    tar -tf "$filepath" 2>/dev/null | head -100
                case '*.zip'
                    if type -q unzip
                        unzip -l "$filepath" 2>/dev/null | head -100
                    else
                        file -- "$filepath" 2>/dev/null
                    end
                case '*'
                    file -- "$filepath" 2>/dev/null
            end
        case '*'
            echo "Binary: $filepath"
            file -- "$filepath" 2>/dev/null
    end
end

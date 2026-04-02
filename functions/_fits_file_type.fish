function _fits_file_type --description "Detect file type category by extension, falling back to MIME"
    set -l filepath $argv[1]

    if not test -f "$filepath"
        echo unknown
        return
    end

    # Fast path: detect by extension (avoids spawning `file` command)
    switch (string lower -- "$filepath")
        case '*.txt' '*.md' '*.rst' '*.log' '*.csv' '*.tsv' '*.cfg' '*.ini' '*.conf' \
             '*.json' '*.yaml' '*.yml' '*.toml' '*.xml' '*.html' '*.htm' '*.css' \
             '*.js' '*.jsx' '*.ts' '*.tsx' '*.mjs' '*.cjs' '*.vue' '*.svelte' \
             '*.sh' '*.bash' '*.zsh' '*.fish' '*.py' '*.rb' '*.pl' '*.lua' '*.tcl' \
             '*.c' '*.h' '*.cpp' '*.hpp' '*.cc' '*.cxx' '*.cs' '*.java' '*.kt' '*.kts' \
             '*.go' '*.rs' '*.swift' '*.m' '*.mm' '*.zig' '*.nim' '*.v' '*.d' \
             '*.r' '*.R' '*.jl' '*.ex' '*.exs' '*.erl' '*.hrl' '*.hs' '*.ml' '*.mli' \
             '*.clj' '*.cljs' '*.cljc' '*.el' '*.lisp' '*.scm' '*.rkt' \
             '*.sql' '*.graphql' '*.gql' '*.proto' '*.thrift' \
             '*.dockerfile' '*.mk' '*.cmake' '*.gradle' '*.sbt' \
             '*.tf' '*.hcl' '*.nix' '*.dhall' \
             '*.diff' '*.patch' '*.env' '*.envrc' '*.editorconfig' '*.gitignore' \
             '*.ps1' '*.psm1' '*.psd1' '*.bat' '*.cmd' \
             'Makefile' 'Dockerfile' 'Vagrantfile' 'Gemfile' 'Rakefile' 'Brewfile' \
             'CMakeLists.txt' '*.lock'
            echo text
        case '*.jpg' '*.jpeg' '*.png' '*.gif' '*.bmp' '*.svg' '*.webp' '*.ico' \
             '*.tiff' '*.tif' '*.heic' '*.heif' '*.avif'
            echo image
        case '*.pdf'
            echo pdf
        case '*.tar.gz' '*.tgz' '*.tar.bz2' '*.tbz2' '*.tar.xz' '*.txz' '*.tar.zst' \
             '*.tar' '*.zip' '*.7z' '*.rar' '*.gz' '*.bz2' '*.xz' '*.zst' '*.lz4'
            echo archive
        case '*'
            # Slow path: fall back to `file` for unknown extensions
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
end

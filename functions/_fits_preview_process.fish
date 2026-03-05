function _fits_preview_process --description "Preview process details"
    set -l pid (string split -m 1 ' ' -- "$argv[1]")[1]

    if test -z "$pid"
        return
    end

    if type -q procs
        procs --tree --watch-interval=0 "$pid" 2>/dev/null
    else
        ps -p "$pid" -o pid,ppid,user,%cpu,%mem,start,command 2>/dev/null
    end
end

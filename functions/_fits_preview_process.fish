function _fits_preview_process --description "Preview process details"
    set -l pid (string split -m 1 ' ' -- (string trim -l -- "$argv[1]"))[1]

    if test -z "$pid"
        return
    end

    if set -q MSYSTEM
        # procs is a native tool and can't look up MSYS2 pids reliably
        ps -p "$pid" 2>/dev/null
    else if type -q procs
        procs --tree --color=always --pager=disable "$pid" 2>/dev/null
    else
        ps -p "$pid" -o pid,ppid,user,%cpu,%mem,start,command 2>/dev/null
        or ps -p "$pid" 2>/dev/null
    end
end

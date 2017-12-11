_transfer_exit_code() {
    while read line
    do
        case $line in
            ^[0-9] | ^[1-9][0-9] | ^11[0-9] | ^12[0-7] ) return ${line#^} ;;
            * ) printf '%s\n' "$line" ;;
        esac
    done
    return 1  # ksh93e lacks pipefail; we get here when 'rscript' failed
}

rscript() {
    case $# in
        0 | 1 )
            echo "$progname: BUG: Usage: rscript SCRIPT-NAME HOSTNAME [ARGS]..." >&2 ;;
        * ) script_name=$1 ; shift
            hostname=$1 ; shift ;;
    esac
    # Trace callers script if we ourselves are being traced
    if ${debug-false}
    then
        _set_x='set -x'
    else
        case $- in
            *x* ) _set_x='set -x' ;;
        esac
    fi

    rexec $hostname /usr/bin/ksh93 -s "$@" <<EOS | _transfer_exit_code
set - "$@"  # Only reasonable way to pass through function arguments

# Work around AIX ksh93 return code of exit ignored by trap
fail() {
    return \$1
}

# Our hook to capture the exit code for rexec who dumbly swallows it
trap 'rc=\$?; echo ^\$rc; exit \$rc' EXIT

_trap() {
    case \$2 in
        EXIT ) \\trap "rc=\\\$? ; \$1 ; echo ^\\\$rc ; exit \\\$rc" ;;
        * ) \\trap "\$@" ;;
    esac
}
alias trap=_trap

PS4='+$script_name:\$(( LINENO - 20 )) (\$SECONDS) '
$_set_x

# The callers script
$(cat)
EOS
}

#!/usr/bin/env bash

# shellcheck disable=SC2059,SC2209,SC2214,SC2215

export PS4='+${BASH_SOURCE}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '

set -e
set -u
set -o pipefail

readonly version=0

: "${LINES:=$(tput lines)}"
export LINES
: "${COLUMNS:=$(tput cols)}"
export COLUMNS

fmt=fmt
readonly fmt_width=$((COLUMNS - 5))
function -setup-terminal() {
    if [[ ! -t 1 ]]; then
        readonly fmt=cat
        return 0
    fi

    if ((fmt_width < 10)); then
        echo "$0: Your terminal is too narrow." >&2
        readonly fmt=cat
        return 0
    fi

    fmt="fmt -w $fmt_width"
    readonly fmt
}

function -setup-colors() {
    local -r ncolors=$(tput colors)

    if $color && ((${ncolors-0} > 7)); then
        printf -v pgreen "$(tput setaf 2)"
        printf -v preset "$(tput sgr0)"
    else
        pgreen=''
        preset=''
    fi
    readonly pgreen
    readonly preset
}

function -maybe-debug() {
    case $debug in
    0) debug=false ;;
    1) debug=true ;;
    *)
        debug=true
        set -x
        ;;
    esac
}

function -print-usage() {
    cat <<EOU | $fmt
Usage: $0 [OPTION]... [TASK]...
EOU
}

function -print-help() {
    echo "$0, version $version"
    -print-usage
    cat <<EOH

Options:
  -c, --color          Print in color
      --no-color       Print without color
  -d, --debug          Print debug output while running.  Repeat for more output
  -e, --prefix=PREFIX  Prefix dry run output (default '> ')
  -h, --help           Print help and exit normally
  -n, --dry-run        Do nothing (dry run); echo actions
  -v, --verbose        Verbose output
  --version            Print version and exit normally

Tasks:
EOH

    for task in "${tasks[@]}"; do
        local help_fn="-$task-help"
        echo "  * $task"
        if declare -F -- "$help_fn" >/dev/null 2>&1; then
            $help_fn | -format-help
        fi
    done
}

function -format-help() {
    $fmt -w $((fmt_width - 8)) | sed 's/^/       /'
}

function -print-version() {
    cat <<EOV
${0##*/} $version
This is free and unencumbered software released into the public domain.
For more information, please refer to <http://unlicense.org/>.

Written by B. K. Oxley (binkley).
EOV
}

function -find-in-tasks() {
    local cmd="$1"
    for task in "${tasks[@]}"; do
        [[ "$cmd" == "$task" ]] && return 0
    done
    return 1
}

function -check-cmd() {
    local cmd="$1"

    if ! -find-in-tasks "$cmd"; then
        echo "$0: $cmd: Unknown command." >&2
        echo "Try '$0 --help' for more information." >&2
        -print-usage >&2
        exit 2
    fi
}

for f in "${0%/*}/functions"/*.sh; do
    # shellcheck source=functions
    source "$f"
done

mapfile -t tasks < <(declare -F | cut -d' ' -f3 | grep -v '^-' | sort)
readonly tasks

-setup-terminal

[[ -t 1 ]] && color=true || color=false
((debug = 0)) || true
prefix='> '
print=echo
pwd=pwd
run= # Nothing, unless dry run
verbose=false
while getopts :cdE:hnv-: opt; do
    [[ $opt == - ]] && opt=${OPTARG%%=*} OPTARG=${OPTARG#*=}
    case $opt in
    E | prefix) prefix="$OPTARG" ;;
    c | color) color=true ;;
    no-color) color=false ;;
    d | debug) ((++debug)) ;;
    h | help)
        -print-help
        exit 0
        ;;
    n | dry-run)
        print="echo $prefix$print" pwd="echo $prefix$pwd"
        run=echo
        ;;
    v | verbose) verbose=true ;;
    version)
        -print-version
        exit 0
        ;;
    *)
        -print-usage >&2
        exit 2
        ;;
    esac
done
shift $((OPTIND - 1))
readonly print
readonly verbose

-setup-colors
-maybe-debug
readonly debug

commands=($(make -f functions/Runfile "$@"))

for cmd in "${commands[@]}"; do
    if ! -find-in-tasks "$cmd"; then
        echo "$0: $cmd: Unknown command." >&2
        echo "Try '$0 --help' for more information." >&2
        -print-usage >&2
        exit 2
    fi
    $run "$cmd"
done

#!/usr/bin/env bash

# Suppress various Shellcheck warnings.  Shellcheck is recommended, and
# IntelliJ will download it for you.  See https://www.shellcheck.net/
# shellcheck disable=SC2059,SC2209,SC2214,SC2215

# Better debugging output when using `bash -x <script>`
export PS4='+${BASH_SOURCE}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '

# Enable good runtime checks by Bash when executing the script
set -e
set -u
set -o pipefail
IFS=$'\t\n' # Ignore environment for parsing - security and good sense

readonly version=0 ## EDITABLE, PERHAPS MANUALLY OR THROUGH A CI PROCESS

readonly progname="$0"

# Meaningful to terminal programs displaying information sensibly
: "${LINES:=$(tput lines)}"
export LINES
: "${COLUMNS:=$(tput cols)}"
export COLUMNS

# Meaningful to terminal programs, especially when showing "help"
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
Usage: $progname [OPTION]... [TASK]...
EOU
}

function -print-help() {
    echo "$progname, version $version"
    -print-usage
    cat <<EOH

Options:
  -S, --save[=DIR]     Save output to DIR (default in place) named "out"
  -c, --color          Print in color
      --no-color       Print without color
  -d, --debug          Print debug output while running.
                       Repeat for more output
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

# Follow GNU standards for command line tools
function -print-version() {
    cat <<EOV
${0##*/} $version
This is free and unencumbered software released into the public domain.
For more information, please refer to <http://unlicense.org/>.

Written by B. K. Oxley (binkley).
EOV
}

# Only needed for "task-based" scripts, ala how git has subcommands
function -find-in-tasks() {
    local cmd="$1"
    shift
    for task in "${tasks[@]}"; do
        [[ "$cmd" == "$task" ]] && return 0
    done
    return 1
}

# Only needed for "task-based" scripts, ala how git has subcommands
function -check-cmd() {
    local cmd="$1"

    if ! -find-in-tasks "$cmd"; then
        echo "$progname: $cmd: Unknown command." >&2
        echo "Try '$progname --help' for more information." >&2
        -print-usage >&2
        exit 2
    fi
}

# Only needed for "task-based" scripts, ala how git has subcommands
for f in "${0%/*}/functions"/*.sh; do
    # shellcheck source=functions
    source "$f"
done

# Only needed for "task-based" scripts, ala how git has subcommands
mapfile -t tasks < <(declare -F | cut -d' ' -f3 | grep -v '^-' | sort)
readonly tasks

# Used for paging output, particularly "help"
-setup-terminal

function -check-savefile() {
    local savedir="$1"
}

# Rule of thumb: Define default values for things which options can change
[[ -t 1 ]] && color=true || color=false
((debug = 0)) || true
prefix='> '
print=echo
pwd=pwd
run= # Nothing, unless dry run
verbose=false
# Note the "-" as an option: This supports long options ("--help" vs "-h")
while getopts :E:Scdhns:v-: opt; do
    # Complex, but addresses "--foo=bar" type options
    [[ $opt == - ]] && opt=${OPTARG%%=*} OPTARG=${OPTARG#*=}
    case $opt in
    E | prefix) prefix="$OPTARG" ;;
    S | save)
        savefile="$PWD/out"
        -check-savefile "$savefile"
        ;;
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
    s)
        savefile="$OPTARG/out"
        -check-savefile "$savefile"
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

# Heyo, this script is a template.
# So I am bravely dumping info and quiting.

echo "I am $progname (checking ... $0)"

# Only needed for "task-based" scripts, ala git subcommands
# shellcheck disable=SC2207
commands=($(make -f functions/Runfile "$@"))

# For "task-based" scripts, ala git commands
for cmd in "${commands[@]}"; do
    if ! -find-in-tasks "$cmd"; then
        echo "$progname: $cmd: Unknown command." >&2
        echo "Try '$progname --help' for more information." >&2
        -print-usage >&2
        exit 2
    fi
    $run "$cmd"
done

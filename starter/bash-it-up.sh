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

scriptdir="."
[[ "$0" == */* ]] && scriptdir="${0%/*}"
readonly scriptdir

# Meaningful to terminal programs displaying information sensibly
[[ -t 1 ]] && read -r LINES COLUMNS < <(stty size 2>/dev/null) || true
: "${LINES:=24}"
export LINES
: "${COLUMNS:=80}"
export COLUMNS

# Meaningful to terminal programs, especially when showing "help"
fmt=(fmt)
readonly fmt_width=$((COLUMNS - 5))
function -setup-terminal() {
    if [[ ! -t 1 ]]; then
        readonly fmt=(cat)
        readonly pager=(cat)
        return 0
    fi

    if command -v less >/dev/null 2>&1; then
        pager=(less -F -R -X)
    elif command -v more >/dev/null 2>&1; then
        pager=(more)
    else
        pager=(cat)
    fi
    readonly pager

    if ((fmt_width < 10)); then
        echo "$progname: ${pbold}${pred}Your terminal is too narrow${preset}." >&2
        readonly fmt=(cat)
        return 0
    fi

    fmt=(fmt -w $fmt_width)
    readonly fmt
}

function -setup-colors() {
    if [[ -n "${NO_COLOR-}" ]]; then
        color=false
    fi

    if $color; then
        pbold=$'\033[1m'
        pred=$'\033[0;31m'
        pgreen=$'\033[0;32m'
        pyellow=$'\033[0;33m'
        punderline=$'\033[4m'
        preset=$'\033[0m'
    else
        pbold=''
        pred=''
        pgreen=''
        pyellow=''
        punderline=''
        preset=''
    fi
    readonly pbold
    readonly pred
    readonly pgreen
    readonly pyellow
    readonly punderline
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
${pbold}Usage:${preset} $progname [OPTION]... [TASK]...
EOU
}

function -print-help() {
    echo "${pbold}$progname${preset}, version $version"
    -print-usage
    cat <<EOH

${pbold}Options:${preset}
  ${pbold}${pgreen}-S, --save${preset}[=${punderline}DIR${preset}]     Save output to DIR (default in place) named "out"
  ${pbold}${pgreen}-c, --color${preset}          Print in color
      ${pbold}${pgreen}--no-color${preset}       Print without color
  ${pbold}${pgreen}-d, --debug${preset}          Print debug output while running.
                       Repeat for more output
  ${pbold}${pgreen}-e, --prefix${preset}=${punderline}PREFIX${preset}  Prefix dry run output (default '> ')
  ${pbold}${pgreen}-h, --help${preset}           Print help and exit normally
  ${pbold}${pgreen}-n, --dry-run${preset}        Do nothing (dry run); echo actions
  ${pbold}${pgreen}-v, --verbose${preset}        Verbose output
      ${pbold}${pgreen}--version${preset}        Print version and exit normally

${pbold}Tasks:${preset}
EOH

    for task in "${tasks[@]}"; do
        local help_fn="-$task-help"
        echo "  * ${pbold}${pgreen}$task${preset}"
        if declare -F -- "$help_fn" >/dev/null 2>&1; then
            $help_fn | -format-help
        fi
    done
}

function -format-help() {
    if [[ "$fmt" == "cat" ]]; then
        cat | sed 's/^/       /'
    else
        $fmt -w $((fmt_width - 8)) | sed 's/^/       /'
    fi
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
        echo "$progname: $cmd: ${pred}Unknown command${preset}." >&2
        echo "Try '$progname --help' for more information." >&2
        -print-usage >&2
        exit 2
    fi
}

# Only needed for "task-based" scripts, ala how git has subcommands
# Unlike git, these are relative to the script location in "functions"
for f in "$scriptdir/functions"/*.sh; do
    # shellcheck source=functions
    [[ -e "$f" ]] && source "$f" || true
done

# Only needed for "task-based" scripts, ala how git has subcommands
mapfile -t tasks < <(declare -F | cut -d' ' -f3 | grep -v '^-' | sort)
readonly tasks

# Rule of thumb: Define default values for things which options can change
[[ -t 1 ]] && color=true || color=false
((debug = 0)) || true
prefix='> '
print=echo
pwd=pwd
run= # Nothing, unless dry run
verbose=false
# Note the "-" as an option: This supports long options ("--help" vs "-h")
while getopts :E:Scdhnv-: opt; do
    # Complex, but addresses "--foo=bar" type options
    [[ $opt == - ]] && opt=${OPTARG%%=*} OPTARG=${OPTARG#*=}
    case $opt in
    E | prefix) prefix="$OPTARG" ;;
    S) savefile="./out" ;;
    c | color) color=true ;;
    no-color) color=false ;;
    d | debug) ((++debug)) ;;
    h | help)
        -setup-colors
        -setup-terminal
        -print-help | "${pager[@]}"
        exit 0
        ;;
    n | dry-run)
        print="echo $prefix$print"
        pwd="echo $prefix$pwd"
        run=echo
        ;;
    save) [[ -n "$OPTARG" ]] && savefile="$OPTARG/out" || savefile="./out" ;;
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

# Used for paging output, particularly "help"
-setup-terminal

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
        echo "$progname: $cmd: ${pbold}${pred}Unknown command${preset}." >&2
        echo "Try '$progname --help' for more information." >&2
        -print-usage >&2
        exit 2
    fi
    $run "$cmd"
done

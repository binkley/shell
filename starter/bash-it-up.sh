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
set -E # Inherit ERR (error) trap in functions and subshells
# Run the last command of a pipe in the current shell. This lets you modify
# shell variables from the last pipline state and avoid awkward workarounds
shopt -s lastpipe
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
function _setup-terminal() {
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
        _fail-error 1 "Your terminal is too narrow."
    fi

    fmt=(fmt -w $fmt_width)
    readonly fmt
}

function _setup-colors() {
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

function _fail-error() {
    local -r code="$1"
    shift
    echo "$progname: ${pbold}${pred}$*${preset}" >&2
    exit "$code"
}

function _on-error() {
    # Call with CODE-NUMBER for exit followed by your error message
    local -r code="$?"
    trap - ERR # Prevent infinite loops if a command inside the trap fails
    _fail-error "$code" "Command '$BASH_COMMAND' failed at line $LINENO."
}

function _on-exit() {
    # If you have cleanup to always do, put it here, eg rm -rf "$tmpfile"
    # This starter script has no cleanup so 'true' means nothing to do
    true
}

function _maybe-debug() {
    case $debug in
    0) debug=false ;;
    1) debug=true ;;
    *)
        debug=true
        set -x
        ;;
    esac
}

# Handle exit codes gracefully and provide cleanup if needed
trap _on-exit EXIT
trap _on-error ERR

function _print-usage() {
    cat <<EOU | $fmt
${pbold}Usage:${preset} $progname [OPTION]... [TASK]...
EOU
}

function _print-help() {
    echo "${pbold}$progname${preset}, version $version"
    _print-usage
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
        local help_fn="_$task-help"
        echo "  * ${pbold}${pgreen}$task${preset}"
        if declare -F -- "$help_fn" >/dev/null 2>&1; then
            $help_fn | _format-help
        fi
    done
}

function _format-help() {
    if [[ "$fmt" == "cat" ]]; then
        cat | sed 's/^/       /'
    else
        $fmt -w $((fmt_width - 8)) | sed 's/^/       /'
    fi
}

# Follow GNU standards for command line tools
function _print-version() {
    cat <<EOV
${0##*/} $version
This is free and unencumbered software released into the public domain.
For more information, please refer to <http://unlicense.org/>.

Written by B. K. Oxley (binkley).
EOV
}

# Only needed for "task-based" scripts, ala how git has subcommands
function _find-in-tasks() {
    local command="$1"
    shift
    for task in "${tasks[@]}"; do
        [[ "$command" == "$task" ]] && return 0
    done
    return 1
}

# Only needed for "task-based" scripts, ala how git has subcommands
function _check-command() {
    local command="$1"

    if ! _find-in-tasks "$command"; then
        echo "Try '$progname --help' for more information." >&2
        _print-usage >&2
        _fail-error 2 "$command: Unknown command."
    fi
}

# Only needed for "task-based" scripts, ala how git has subcommands
shopt -s nullglob
for f in "$scriptdir/functions"/*.sh; do
    # shellcheck source=functions
    source "$f"
done
shopt -u nullglob

# Only needed for "task-based" scripts, ala how git has subcommands
declare -F | cut -d' ' -f3 | grep -v '^_' | sort | mapfile -t tasks
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
        _setup-colors
        _setup-terminal
        _print-help | "${pager[@]}"
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
        _print-version
        exit 0
        ;;
    *)
        _print-usage >&2
        exit 2
        ;;
    esac
done
shift $((OPTIND - 1))
readonly print
readonly verbose

_setup-colors

# Used for paging output, particularly "help"
_setup-terminal

_maybe-debug
readonly debug

# Heyo, this script is a template.
# So I am bravely dumping info and quiting.

echo "I am $progname (checking ... $0)"

# For "task-based" scripts, ala git subcommands
make -f functions/Runfile "$@" | mapfile -t commands

# For "task-based" scripts, ala git commands
for command in "${commands[@]}"; do
    if ! _find-in-tasks "$command"; then
        echo "Try '$progname --help' for more information." >&2
        _print-usage >&2
        _fail-error 2 "$command: Unknown command."
    fi
    $run "$command"
done


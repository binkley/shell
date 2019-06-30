#!/usr/bin/env bash

# shellcheck disable=SC2059,SC2209,SC2214,SC2215

export PS4='+${BASH_SOURCE}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '

set -e
set -u
set -o pipefail

readonly progname="${0##*/}"
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
    echo "$progname: Your terminal is too narrow." >&2
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
  -c, --color     Print in color
      --no-color  Print without color
  -d, --debug     Print debug output while running.  Repeat for more output
  -h, --help      Print help and exit normally
  -n, --dry-run   Do nothing (dry run); echo actions
  -v, --verbose   Verbose output

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
    echo "$progname: $cmd: Unknown command." >&2
    echo "Try '$progname --help' for more information." >&2
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
print=echo
pwd=pwd
verbose=false
while getopts :cdhnv-: opt; do
  [[ $opt == - ]] && opt=${OPTARG%%=*} OPTARG=${OPTARG#*=}
  case $opt in
  c | color) color=true ;;
  no-color) color=false ;;
  d | debug) ((++debug)) ;;
  h | help)
    -print-help
    exit 0
    ;;
  n | dry-run) print="echo > $print" pwd="echo > $pwd" ;;
  v | verbose) verbose=true ;;
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

echo 'Try help, maybe?'

for cmd; do
  if ! -find-in-tasks "$cmd"; then
    echo "$progname: $cmd: Unknown command." >&2
    echo "Try '$progname --help' for more information." >&2
    -print-usage >&2
    exit 2
  fi
done

"$@"

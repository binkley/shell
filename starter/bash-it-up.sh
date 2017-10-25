#!/usr/bin/env bash

export PS4='+${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): } '

set -e
set -u
set -o pipefail

readonly progname="${0##*/}"
readonly version=0

function -setup-colors {
    local -r ncolors=$(tput colors)

    if $color && (( ${ncolors-0} > 7 ))
    then
        printf -v pgreen "$(tput setaf 2)"
        printf -v preset "$(tput sgr0)"
    else
        pgreen=''
        preset=''
    fi
    readonly pgreen
    readonly preset
}

function -enable-debug {
    set -x
}

function -print-usage {
    cat <<EOU
Usage: $progname [-c|--color][-d|--debug][-h|--help][-n|--dry-run][-v|--verbose]
EOU
}

function -print-help {
    echo "$progname, version $version"
    -print-usage
    cat <<EOH

Flags:
  -c, --color    Print in color
  -d, --debug    Print debug output while running
  -h, --help     Print help and exit normally
  -n, --dry-run  Do nothing (dry run); echo actions
  -v, --verbose  Verbose output
EOH
}

[[ -t 1 ]] && color=true || color=false
debug=false
print=echo
pwd=pwd
verbose=false
while getopts :-: opt
do
    [[ - == $opt ]] && opt=${OPTARG%%=*} OPTARG=${OPTARG#*=}
    case $opt in
    c | color ) color=true ;;
    d | debug ) -enable-debug ;;
    h | help ) -print-help ; exit 0 ;;
    n | dry-run ) print="echo $print" pwd="echo $pwd" ;;
    v | verbose ) verbose=true ;;
    * ) -print-usage >&2 ; exit 2 ;;
    esac
done
shift $((OPTIND - 1))

case $# in
0 ) ;;
* ) -print-usage >&2 ; exit 2 ;;
esac

-setup-colors

$print "${pgreen}I am green.${preset}"
$pwd

#!/usr/bin/env bash

set -e
set -u

function setup_colors()
{
    # TODO: Should test that 'tput color' > 0?
    pblack=$(tput setaf 0)
    pred=$(tput setaf 1)
    pgreen=$(tput setaf 2)
    pyellow=$(tput setaf 3)
    pblue=$(tput setaf 4)
    pmagenta=$(tput setaf 5)
    pcyan=$(tput setaf 6)
    pwhite=$(tput setaf 7)
    prev=$(tput rev)
    pbold=$(tput bold)
    preset=$(tput sgr0)
}

function enable_debug()
{
    export debug=true
    export PS4='+${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): } '
    set -o pipefail
    set -o xtrace
}
${debug-false} && enable_debug

# Disable color, etc., if a pipe
[[ ! -t 1 ]] && export TERM=dumb

function print_usage()
{
    cat <<EOU
Usage: $0 [-c|--color][-d|--debug][-h|--help][-n|--dry-run][-v|--verbose]
EOU
}

function print_help()
{
    print_usage
    cat <<EOH

Flags:
  -c, --color    Print in color
  -d, --debug    Print debug output while running
  -h, --help     Print help and exit normally
  -n, --dry-run  Do nothing (dry run); echo actions
  -v, --verbose  Verbose output
EOH
}

debug=false
pwd=pwd
verbose=false
while getopts :-: opt
do
    [[ - == $opt ]] && opt=${OPTARG%%=*} OPTARG=${OPTARG%*=}
    case $opt in
    c | color ) setup_colors ;;
    d | debug ) enable_debug ;;
    h | help ) print_help ; exit 0 ;;
    n | dry-run ) pwd="echo $pwd" ;;
    v | verbose ) verbose=true ;;
    * ) print_usage >&2 ; exit 2 ;;
    esac
done
shift $((OPTIND - 1))

case $# in
0 ) ;;
* ) print_usage >&2 ; exit 2 ;;
esac

$pwd

#!/usr/bin/env bash

function enable_debug()
{
    export debug=true
    export PS4='+${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): } '
    set -o functrace
    set -o pipefail
    set -o xtrace
}

if ${debug-false}
then
    enable_debug
fi

function print_usage()
{
    cat <<EOU
Usage: $0 [-d|--debug][-h|--help][-n|--dry-run][-v|--verbose]
EOU
}

function print_help()
{
    print_usage
    cat <<EOH

Flags:
  -d, --debug    Print debug output while running
  -h, --help     Print help and exit normally
  -n, --dry-run  Do nothing (dry run); echo actions
  -v, --verbose  Verbose output
EOH
}

debug=false
pwd=pwd
verbose=false
while getopts :J:dhnv-: opt
do
    [[ - == $opt ]] && opt=$OPTARG
    case $opt in
    d | debug ) enable_debug ;;
    h | help ) print_help ; exit 0 ;;
    n | dry-run ) pwd='echo pwd' ;;
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

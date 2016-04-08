#!/bin/bash

function print_usage()
{
    cat <<EOU
Usage: $0 [-d|--debug]|[-q|--quiet] <script>
EOU
}

function enable_debug()
{
    export debug=true
    export PS4='+${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): } '
    set -o functrace
    set -o pipefail
    set -o xtrace
}

quiet=false
while getopts :dq-: opt
do
    [[ - == $opt ]] && opt=${OPTARG%%=*} OPTARG=${OPTARG#*=}
    case $opt in
    d | debug ) enable_debug ;;
    q | quiet ) quiet=true ;;
    * ) print_usage >&2 ; exit 3 ;;
    esac
done
shift $((OPTIND - 1))

case $# in
1 ) script=$1 ;;
* ) print_usage >&2 ; exit 3 ;;
esac

rootdir=$(dirname $0)

. $rootdir/test-functions.sh

let passed=0 failed=0 errored=0
for t in $rootdir/t/*.sh
do
    if ! $quiet
    then
        echo t/${t##*/}:
    fi
    . $t
done

if ! $quiet
then
    echo "Summary: $passed PASSED, $failed FAILED, $errored ERROR"
fi

if (( 0 < errored ))
then
    exit 2
elif (( 0 < failed ))
then
    exit 1
fi

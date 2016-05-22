#!/bin/bash

export PS4='+${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): } '

function __setup_colors()
{
    [[ -t 1 ]] || return
    local -r ncolors=$(tput colors)
    [[ -n "$ncolors" && ncolors -ge 8 ]] || return
    readonly pgreen=$(printf "\e[32m")
    readonly pred=$(printf "\e[31m")
    readonly pboldred=$(printf "\e[31;1m")
    readonly preset=$(printf "\e[0m")
}

function __print_usage {
    cat <<EOU
Usage: $0 [-c|--color][-d|--debug]|[-q|--quiet] <tests ...>
EOU
}

function __print_help {
    __print_usage
    cat <<'EOH'

Options:
  -c,--color    Print in color
  -d,--debug    Print extra output
  -q,--quiet    Print minimal output
EOH
}

function __enable_debug()
{
    export debug=true
    export PS4='+${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): } '
    set -o pipefail
    set -o xtrace
    echo "$0: Called with $@"
}

function _register {
    case $# in
    1 ) local -r name=$1 arity=0 ;;
    2 ) local -r name=$1 arity=$2 ;;
    esac
    case $(type -t $name) in
    function ) ;;
    * ) echo "$0: $FUNCNAME: Not a function: $name" >&2
        exit 3 ;;
    esac
    read -d '' -r wrapper <<EOF
function $name {
    # Original function
    $(declare -f $name | sed '1,2d;$d')

    __e=\$?
    shift $arity
    if (( 0 < __e || 0 == \$# ))
    then
        __tally \$__e
    else
        "\$@"
        __e=\$?
        __tally \$__e
    fi
}
EOF
    eval "$wrapper"
}

function _start {
    local __tallied=false
    local __e=0
    pushd $PWD >/dev/null
    "$@"
    __tally $?
    while popd >/dev/null 2>&1 ; do : ; done
}

let __passed=0 __failed=0 __errored=0
function __tally {
    local -r __e=$1
    $__tallied && return $__e
    __tallied=true
    case $__e in
    0 ) let ++__passed ;;
    1 ) let ++__failed ;;
    * ) let ++__errored ;;
    esac
    _print_result $__e
    return $__e
}

[[ -t 1 ]] && _color=true || _color=false
_quiet=false
while getopts :cdhq-: opt
do
    [[ - == $opt ]] && opt=${OPTARG%%=*} OPTARG=${OPTARG#*=}
    case $opt in
    c | _color ) _color=true ;;
    d | debug ) __enable_debug "$@" ;;
    h | help ) __print_help ; exit 0 ;;
    q | _quiet ) _quiet=true ;;
    * ) __print_usage >&2 ; exit 3 ;;
    esac
done
shift $((OPTIND - 1))

$_color && __setup_colors

case $# in
0 ) __print_usage >&2 ; exit 3 ;;
esac

{
    pushd $(dirname $0)
    root_dir=$(pwd -P)
    popd
} >/dev/null

for f in $root_dir/f/*.sh
do
    . $f
done

for t in "$@"
do
    if [[ -d "$t" ]]
    then
        set -- $(find $t -type f -name \*.sh)
    else
        set -- $t
    fi
done

for t in "$@"
do
    if ! $_quiet
    then
        s=${t##*/}
        s=${s%.sh}
        echo "${pbold}Script $s:${preset}"
    fi
    let __last_passed=$__passed
    let __last_failed=$__failed
    let __last_errorer=$__errored
    pushd $PWD >/dev/null
    . $t
    while popd >/dev/null 2>&1 ; do : ; done
    let __t_passed=$((__passed - __last_passed))
    let __t_failed=$((__failed - __last_failed))
    let __t_errored=$((__errored - __last_errored))
    if ! $_quiet
    then
        __all=()
        (( 0 == __t_errored )) || __all+=("$__t_errored errored")
        (( 0 == __t_failed )) || __all+=("$__t_failed failed")
        (( 0 == __t_passed )) || __all+=("$__t_passed passed")
        IFS=, eval '__s="${__all[*]}"'
        echo "${__s//,/, }"
    fi
done

if ! $_quiet
then
    (( 0 == __passed )) && ppassed= || ppassed=${pgreen}
    (( 0 == __failed )) && pfailed= || pfailed=${pred}
    (( 0 == __errored )) && perrored= || perrored=${pboldred}
    cat <<EOS
${pbold}Summary${preset}: ${ppassed}$__passed PASSED${preset}, ${pfailed}$__failed FAILED${preset}, ${perrored}$__errored ERRORED${preset}
EOS
fi

if (( 0 < __errored ))
then
    exit 2
elif (( 0 < __failed ))
then
    exit 1
fi

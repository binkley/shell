# vi: ft=bash
# Source me

function _print_result {
    local -r __e=$1
    $quiet && return $__e
    case $__e in
    0 ) echo -e $pgreen$pcheckmark$preset $_scenario_name ;;
    1 ) echo -e $pred$pballotx$preset $_scenario_name ;;
    * ) echo -e $pboldred$pinterrobang$preset $_scenario_name ;;
    esac
}

function AND {
    "$@"
}

function SCENARIO {
    local -r _scenario_name="$1"
    shift
    _start "$@"
}

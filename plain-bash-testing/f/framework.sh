# vi: ft=bash
# Source me

function _print_result {
    local -r exit_code=$1
    $_quiet && return $exit_code
    case $exit_code in
    0 ) echo -e $pgreen$pcheckmark$preset $scenario_name ;;
    1 ) echo -e $pred$pballotx$preset $scenario_name ;;
    * ) echo -e $pboldred$pinterrobang$preset $scenario_name ;;
    esac
}

function AND {
    "$@"
}

function SCENARIO {
    local -r scenario_name="$1"
    shift
    _start "$@"
}

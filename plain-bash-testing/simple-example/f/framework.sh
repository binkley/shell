# vi: ft=bash
# Source me

readonly pcheckmark=$(printf "\xE2\x9C\x93")
readonly ppass=$pgreen$pcheckmark$preset
readonly pballotx=$(printf "\xE2\x9C\x97")
readonly pfail=$pred$pballotx$preset
readonly pinterrobang=$(printf "\xE2\x80\xBD")
readonly perror=$pboldred$pinterrobang$preset

function _print_result {
    local -r exit_code=$1
    $_quiet && return $exit_code
    case $exit_code in
    0 ) echo -e "$ppass $scenario_name" ;;
    1 ) echo -e "$pfail $scenario_name - wanted: $expected_color, got $actual_color" ;;
    * ) echo -e "$perror $scenario_name - exit: $exit_code" ;;
    esac
}

function THEN {
    "$@"
}

function WHEN {
    "$@"
}

function GIVEN {
    "$@"
}

function SCENARIO {
    local -r scenario_name="$1"
    shift
    _start "$@"
}

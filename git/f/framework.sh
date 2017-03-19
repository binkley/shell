# vi: ft=bash
# Source me

printf -v pcheckmark "\xE2\x9C\x93"
readonly pcheckmark
readonly ppass="$pgreen$pcheckmark$preset"
printf -v pballotx "\xE2\x9C\x97"
readonly pballotx
readonly pfail="$pred$pballotx$preset"
printf -v pinterrobang "\xE2\x80\xBD"
readonly pinterrobang
readonly perror="$pboldred$pinterrobang$preset"

function _print_result {
    local -r exit_code=$1
    $_quiet && return $exit_code
    case $exit_code in
    0 ) echo -e "\r$ppass" ;;
    1 ) echo -e "\r$pfail $scenario_name - wanted: $expected_color, got $actual_color" ;;
    * ) echo -e "\r$perror $scenario_name - exit: $exit_code" ;;
    esac
}

function AND {
    "$@"
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
    $_quiet || echo -n ". $scenario_name"
    _start "$@"
}

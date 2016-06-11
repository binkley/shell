# vi: ft=bash
# Source me

printf -v pcheckmark "\xE2\x9C\x93"
readonly pcheckmark
printf -v pballotx "\xE2\x9C\x97"
readonly pballotx
printf -v pinterrobang "\xE2\x80\xBD"
readonly pinterrobang

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

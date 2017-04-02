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
    1 ) echo -e " ($test_function)\r$pfail" ;;
    * ) echo -e " ($test_function) -> $exit_code\r$perror" ;;
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

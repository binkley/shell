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
    local -r _e=$1
    local -r _f=$2
    $_quiet && return $_e
    case $_e in
    0 ) echo -e "\r$ppass" ;;
    1 ) echo -e " ($_f)\r$pfail" ;;
    * ) echo -e " ($_f; exit $_e)\r$perror" ;;
    esac
}

function AND {
    "$@"
}

function SCENARIO {
    local -r scenario_name="$1"
    shift
    $_quiet || echo -n ". $scenario_name"
    _start "$@"
}

printf -v pcheckmark "\xE2\x9C\x93"
readonly pcheckmark
readonly ppass="$pgreen$pcheckmark$preset"
printf -v pballotx "\xE2\x9C\x97"
readonly pballotx
readonly pfail="$pred$pballotx$preset"
printf -v pinterrobang "\xE2\x80\xBD"
readonly pinterrobang
readonly perror="$pboldred$pinterrobang$preset"

function __print-fail-or-diff {
    local -r _e=$1
    local -r _test_function=$2
    echo -e " ($_test_function)\r$pfail"
    [[ -n "$expected" || -n "$actual" ]] || return 0
    cat <<EOD
Expected (on next line):
$expected
Actual (on next line):
$actual

Diff actual (left) vs expected (right):
EOD
    diff --color=always <(echo "$actual") <(echo "$expected")
}

function _print_result {
    local -r _e=$1
    local -r _test_function=$2
    $_quiet && return $_e
    case $_e in
    0 ) echo -e "\r$ppass" ;;
    1 ) __print-fail-or-diff $_e $_test_function ;;
    * ) echo -e " ($_test_function; exit $_e)\r$perror" ;;
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

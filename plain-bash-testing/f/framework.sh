function AND {
    "$@"
}

function SCENARIO {
    local -r scenario_name="$1"
    shift
    $_quiet || echo -n ". $scenario_name"
    _start "$@"
}

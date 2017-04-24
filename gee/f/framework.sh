# vi: ft=bash
# Source me

function _bad_syntax {
    local -r order=$1
    shift
    local valid="$@"
    valid="${valid// / or }"
    readonly valid

    local stack=($(caller 1))
    local -r previous=${stack[1]}

    echo "$0: Bad scenario: No $valid $order $previous: $scenario" >&2
    exit 3
}

function _print_result {
    local -r exit_code=$1
    local stack=($(caller 1))
    local -r previous=${stack[1]}

    if (( 0 == exit_code ))
    then
        if ! $quiet
        then
            echo -e "$pgreen$pcheckmark$preset $description"
        fi
    elif (( 1 == exit_code ))
    then
        : ${expected:=<nothing>} ${actual:=<nothing>}
        echo "$expected}" >$tmpdir/expected
        (( 1 < $(wc -l $tmpdir/expected | cut -d' ' -f1))) \
            && local -r expected_sep=$'\n' || local -r expected_sep=' '
        echo "$actual}" >$tmpdir/actual
        (( 1 < $(wc -l $tmpdir/actual | cut -d' ' -f1))) \
            && local -r actual_sep=$'\n' || local -r actual_sep=' '
        $color && local -r color_flag=always || color_flag=never
        cat <<EOM
$pred$pballotx$preset $description
- ${pbold}Scenario:$preset $scenario
- '$previous' expected${expected_sep}${pcyan}$expected${preset}
- But got${actual_sep}${pcyan}$actual${preset}
- ${pbold}Difference:$reset
$(git --no-pager diff --color=$color_flag --word-diff=plain $tmpdir/expected $tmpdir/actual | sed 1,4d)
- ${pbold}Standard out:$preset
$(<$stdout)
- ${pbold}Standard err:$preset
$(<$stderr)
EOM
    else
        cat <<EOE
$pboldred$pinterrobang$preset $description
- ${pbold}Scenario:$preset $scenario
- $previous exited $exit_code
- ${pbold}Standard out:$preset
$(<$stdout)
- ${pbold}Standard err:$preset
$(<$stderr)
EOE
    fi
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

function nothing {
    "$@"
}

function GIVEN {
    "$@"
}

function _maybe_debug_if_not_passed {
    if $debug && [[ -t 0 && -t 1 ]]
    then
        trap 'cd $old_pwd >/dev/null' RETURN
        local -r old_pwd=$PWD
        cd $tmpdir >/dev/null
        echo ">> Dropping into shell (exited $exit_code): $scenario"
        $SHELL -i
    fi
}

function SCENARIO {
    trap 'rm -rf $tmpdir' RETURN
    local -r tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t ${0##*/})
    local -r stdout=$tmpdir/stdout
    touch $stdout
    local -r stderr=$tmpdir/stderr
    touch $stderr

    local scenario=${FUNCNAME}
    for arg
    do
        case $arg in
        *\'* ) scenario="$scenario \"$arg\"" ;;
        *' '* | *\"* ) scenario="$scenario '$arg'" ;;
        * ) scenario="$scenario $arg" ;;
        esac
    done
    readonly scenario

    local -r description="$1"
    shift

    local __tallied=false
    case $1 in
    GIVEN )
        pushd $PWD >/dev/null
        "$@"
        __tally $?
        popd >/dev/null ;;
    * ) _bad_syntax after GIVEN ;;
    esac

    local exit_code=$?

    # (( 0 != exit_code )) && _maybe_debug_if_not_passed

    return $exit_code
}

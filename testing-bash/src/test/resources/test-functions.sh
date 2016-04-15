# Source me - do not execute

function _bad_clauses()
{
    local message=$1

    echo "$0: Bad scenario: $message: $scenario" >&2
    exit 3
}

function _bad_functions()
{
    local previous=$1
    local next=$2
    shift 2
    for more
    do
        next="$next or $more"
    done

    echo "$0: Bad scenario: No $next after $previous: $scenario" >&2
    exit 3
}

function _assert()
{
    local expected=$1
    local actual=$2

    if [[ "$expected" != "$actual" ]]
    then
        cat <<EOM
FAILED $test_name
Scenario:
$scenario
Expected $expected
Got $actual
Difference:
$(diff <(echo "$expected") <(echo "$actual"))
Standard out:
$(<$tmpdir/out)
Standard err:
$(<$tmpdir/err)
EOM
        return 1
    fi

    if ! $quiet
    then
        echo "PASS $test_name"
    fi
}

function _read_stderr()
{
    # Ignore debug output
    local err=$1
    if $debug
    then
        grep '^[^+]' $err
    else
        cat $err
    fi
}

function _run_script()
{
    local run_script=${script##*/}
    cp $script $tmpdir/$run_script
    chmod a+rx $tmpdir/$run_script

    cd $tmpdir
    ./$run_script "$@" "${command_line[@]}" >$tmpdir/out 2>$tmpdir/err

    return $?
}

function then_exit()
{
    local expected_exit=$1
    shift

    _run_script

    _assert $expected_exit $?
}

function then_expect()
{
    case $# in
    0 ) expected=$(</dev/stdin) ;;
    1 ) expected="$1" ;;
    * ) _bad_clauses "Too many clauses" ;;
    esac

    _run_script -n

    case $? in
    0 ) ;;
    * ) echo "ERROR $test_name: Did not exit normally"
        return 2 ;;
    esac

    # Ignore debugging output
    error="$(_read_stderr $tmpdir/err)"
    if [[ -n "$error" ]]
    then
        echo "ERROR $test_name: $error"
        return 2
    fi

    actual="$(<$tmpdir/out)"

    _assert "$expected" "$actual"
}

function when_run()
{
    local command_line=()
    for arg
    do
        case $arg in
        then_expect | then_exit ) "$@" ; return $? ;;
        * ) command_line=("${command_line[@]}" "$arg") ; shift ;;
        esac
    done

    _bad_functions when_run then_expect then_exit
}

function also_jar()
{
    given_jar "$@"
}

function with_jobs()
{
    mkdir -p $tmpdir/META-INF

    case $1 in
    also_jar | when_run )
        next=$1
        shift
        cat >$tmpdir/META-INF/jobs
        ;;
    * ) case $2 in
        also_jar | when_run )
            echo "$1" >$tmpdir/META-INF/jobs
            next=$2
            shift 2
            ;;
        * ) _bad_functions with_jobs also_jar when_run ;;
        esac
        ;;
    esac

    (cd $tmpdir ; jar cf lib/$jar META-INF/jobs)
    $next "$@"
}

function given_jar()
{
    local jar=$1
    shift

    case $1 in
    with_jobs ) "$@" ;;
    when_run )
        cp ${project.build.directory}/$jar $tmpdir/lib
        "$@" ;;
    * ) _bad_functions given_jar with_jobs when_run ;;
    esac
}

function _maybe_debug_if_not_passed()
{
    if $debug && [[ -t 0 ]]
    then
        pushd $tmpdir
        echo ">> Dropping into shell (exited $exit_code): $scenario"
        $SHELL -i
        popd
    fi
}

trap 'rm -rf "$root_tmpdir"' EXIT
root_tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t ${0##*/})
let test_number=0 && true

function scenario()
{
    local tmpdir=$root_tmpdir/$((++test_number))
    mkdir -p $tmpdir/lib

    local scenario='scenario'
    for arg
    do
        case $arg in
        *\'* ) scenario="$scenario \"$arg\"" ;;
        *' '* | *\"* ) scenario="$scenario '$arg'" ;;
        * ) scenario="$scenario $arg" ;;
        esac
    done

    case $# in
    [0-7] ) _bad_clauses "Not enough clauses" ;;
    esac

    local test_name="$1"
    shift

    case $1 in
    given_jar ) "$@" ;;
    * ) _bad_functions scenario given_jar ;;
    esac

    export exit_code=$?
    case $exit_code in
    0 ) let ++passed ;;
    1 ) _maybe_debug_if_not_passed ; let ++failed  ;;
    2 ) _maybe_debug_if_not_passed ; let ++errored  ;;
    * ) _maybe_debug_if_not_passed ; exit $exit_code ;;
    esac

    return $exit_code
}

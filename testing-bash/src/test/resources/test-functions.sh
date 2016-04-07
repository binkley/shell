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
Expected $expected
Got $actual
EOM
        return 1
    fi

    if ! $quiet
    then
        echo "PASS $test_name"
    fi
}

function then_expect()
{
    case $# in
    0 ) expected=$(</dev/stdin) ;;
    1 ) expected="$1" ;;
    * ) _bad_classes "Too many clauses" ;;
    esac

    run_script=${script##*/}
    cp $script $tmpdir/$run_script
    chmod a+rx $tmpdir/$run_script

    cd $tmpdir
    ./$run_script -n "${command_line[@]}" >$tmpdir/out 2>$tmpdir/err

    error="$(<$tmpdir/err)"
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
        then_expect ) "$@" ; return $? ;;
        * ) command_line=("${command_line[@]}" "$arg") ; shift ;;
        esac
    done

    _bad_functions when_run then_expect
}

function given_existing_jars()
{
    case $1 in
    also_jar | when_run ) "$@" ;;
    * ) _bad_functions given_existing_jars also_jar when_run ;;
    esac
}

function also_jar()
{
    given_jar "$@"
}

function with_jobs()
{
    mkdir -p $tmpdir/META-INF $tmpdir/lib

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
    * ) _bad_functions given_jar with_jobs ;;
    esac
}

function _maybe_debug_if_not_passed()
{
    if $debug
    then
        pushd $tmpdir
        bash
        popd
    fi
}

trap 'rm -rf "$root_tmpdir"' EXIT
root_tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t ${0##*/})
let test_number=0 && true

function scenario()
{
    local tmpdir=$root_tmpdir/$((++test_number))
    mkdir $tmpdir

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

    local test_name="$1" ; shift

    case $1 in
    given_jar | given_existing_jars ) "$@" ;;
    * ) _bad_functions scenario given_jar given_existing_jars ;;
    esac

    exit_code=$?
    case $exit_code in
    0 ) let ++passed ;;
    1 ) _maybe_debug_if_not_passed ; let ++failed  ;;
    2 ) _maybe_debug_if_not_passed ; let ++died  ;;
    * ) _maybe_debug_if_not_passed ; exit $? ;;
    esac

    return $exit_code
}

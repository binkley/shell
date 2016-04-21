# Source me - do not execute

function _bad_clauses()
{
    local message=$1

    echo "$0: Bad scenario: $message: $scenario" >&2
    exit 3
}

function _bad_functions()
{
    local next=$1
    shift
    for more
    do
        next="$next or $more"
    done

    local stack=($(caller 1))
    local previous=${stack[1]}

    echo "$0: Bad scenario: No $next after $previous: $scenario" >&2
    exit 3
}

function _print_result
{
    local stack=($(caller 1))
    local previous=${stack[1]}

    if (( 0 == exit_code ))
    then
        if ! $quiet
        then
            echo "${pgreen}PASS${preset} $test_name"
        fi
    elif (( 1 == exit_code ))
    then
        cat <<EOM
${pred}FAIL${preset} $test_name
- Scenario: $scenario
- $previous expected ${pcyan}$expected${preset}
- But got ${pcyan}$actual${preset}
- Difference:
$(diff <(echo "$expected") <(echo "$actual"))
- Standard out:
$(<$tmpdir/out)
- Standard err:
$(<$tmpdir/err)
EOM
    else
        cat <<EOE
${pmagenta}ERROR${preset} $test_name
- Scenario: $scenario
- Exit code: $exit_code
- Standard out:
$(<$tmpdir/out)
- Standard err:
$(<$tmpdir/err)
EOE
    fi

    return $exit_code
}

function _run_script()
{
    local run_script=${script##*/}
    cp $script $tmpdir/$run_script
    chmod a+rx $tmpdir/$run_script

    trap 'cd $old_pwd' RETURN
    local old_pwd=$PWD
    cd $tmpdir

    # Filter out shell debugging
    ./$run_script "${command_line[@]}" >$tmpdir/out 2>$tmpdir/err
    local exit_code=$?
    grep '^[^+]' $tmpdir/err >$tmpdir/tmp-err
    mv $tmpdir/tmp-err $tmpdir/err

    return $exit_code
}

function with_err()
{
    case $# in
    0 ) local expected=$(</dev/stdin) ;;
    1 ) local expected="$1" ; shift ;;
    * ) _bad_clauses "Too many clauses" ;;
    esac

    local actual="$(<$tmpdir/err)"

    [[ "$expected" == "$actual" ]]
    local exit_code=$?

    _print_result
}

function with_out()
{
    case $# in
    0 ) local expected="$(</dev/stdin)" ;;
    * ) case $1 in
        with_err ) local expected="$(</dev/stdin)" ;;
        * ) local expected="$1" ; shift ;;
        esac ;;
    esac

    (( 0 == $# )) && set -- with_err ''

    local actual="$(<$tmpdir/out)"

    [[ "$expected" == "$actual" ]]
    local exit_code=$?

    case $exit_code in
    0 ) "$@" ;;
    * ) _print_result ;;
    esac
}

function then_exit()
{
    local expected=$1
    shift

    (( 0 == $# )) && set -- with_out '' with_err ''

    _run_script
    local actual=$?

    (( expected == actual ))
    local exit_code=$?

    case $exit_code in
    0 ) "$@" ;;
    * ) _print_result ;;
    esac
}

function when_run()
{
    local command_line=()
    for arg
    do
        case $arg in
        then_exit ) "$@" ; return $? ;;
        * ) command_line=("${command_line[@]}" "$arg") ; shift ;;
        esac
    done

    _bad_functions then_exit
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
        * ) _bad_functions also_jar when_run ;;
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
    * ) _bad_functions with_jobs when_run ;;
    esac
}

function _maybe_debug_if_not_passed()
{
    if $debug && [[ -t 1 ]]
    then
        trap 'cd $old_pwd' RETURN
        local old_pwd=$PWD
        cd $tmpdir
        echo ">> Dropping into shell (exited $exit_code): $scenario"
        $SHELL -i
    fi
}

function scenario()
{
    trap 'rm -rf $tmpdir' RETURN
    local tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t ${0##*/})
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
    * ) _bad_functions given_jar ;;
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

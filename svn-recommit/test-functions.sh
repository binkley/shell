# Source me - do not execute

function _bad_clauses {
    local message=$1

    echo "$0: ${pred}Bad scenario: $message:${preset} ${pmagenta}$scenario${preset}" >&2
    exit 3
}

function _bad_functions {
    local next=$1
    shift
    for more
    do
        next="$next or $more"
    done

    local stack=($(caller 1))
    local previous=${stack[1]}

    echo "$0: ${pred}Bad scenario: No $next after $previous:${preset} ${pmagenta}$scenario${preset}"
     >&2
    exit 3
}

function _print_result {
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
- $previous expected:
${pcyan}$expected${preset}
- But got:
${pcyan}$actual${preset}
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

function _run_script {
    (set -e
        cd $clientdir
        export VISUAL=$rootdir/testing-editor.sh
        export MESSAGE="$replacement"
        $run_script $revision >$tmpdir/buffer 2>>$tmpdir/err)
}

function and_first_line_replaced {
    case $# in
    0 ) ;;
    * ) _bad_clauses ;;
    esac

    local expected="$replacement"
    local actual="$(set -e
        cd $clientdir
        svn propget --revprop -r $revision svn:log)"

    [[ "$expected" == "$actual" ]]
    local exit_code=$?

    _print_result
}

function then_editor_was {
    read -d '' -r expected
    read -d '' -r actual <$tmpdir/buffer

    [[ "$expected" == "$actual" ]]
    local exit_code=$?

    case $exit_code in
    0 ) ;;
    * ) _print_result ; return ;;
    esac

    case $1 in
    and_first_line_replaced ) "$@" ;;
    * ) _bad_functions and_first_line_replaced ;;
    esac
}

function when_recommit {
    case $1 in
    with_message ) "$@" ;;
    * ) _bad_functions with_message ;;
    esac
}

function with_message {
    case ${FUNCNAME[1]} in
    and_add_file | and_move_file )
        local original="$1"
        shift
        (set -e
            cd $clientdir
            svn commit -m "$original") >>$tmpdir/out
        case $1 in
        when_recommit ) "$@" ;;
        * ) _bad_functions when_recommit ;;
        esac ;;
    when_recommit )
        local replacement="$1"
        shift
        _run_script
        case $1 in
        then_editor_was ) "$@" ;;
        * ) _bad_functions then_editor_was ;;
        esac ;;
    esac
}

function and_move_file {
    (set -e
        file='a-file'
        cd $clientdir
        echo OK >$file
        svn add $file
        svn commit -m "added $file"
        svn move $file b-file) >>$tmpdir/out

    local revision=3

    case $1 in
    with_message ) "$@" ;;
    * ) _bad_functions with_message ;;
    esac
}

function and_add_file {
    (set -e
        file='a-file'
        cd $clientdir
        echo OK >$file
        svn add $file) >>$tmpdir/out

    local revision=2

    case $1 in
    with_message ) "$@" ;;
    * ) _bad_functions with_message ;;
    esac
}

function given_repo {
    (set -e
        cd $tmpdir
        svnadmin create repo
        (set -e
            cd repo/hooks
            cp pre-revprop-change.tmpl pre-revprop-change
            chmod a+x pre-revprop-change)
        svn checkout file://$tmpdir/repo client
        cd client
        svn mkdir trunk branches tags
        svn commit -m 'Standard layout') >>$tmpdir/out

     case $1 in
     and_add_file | and_move_file ) "$@" ;;
     * ) _bad_functions and_add_file ;;
     esac
}

function _maybe_debug_if_not_passed {
    if $debug && [[ -t 1 ]]
    then
        cat <<EOM >&2
>> ${pred}Dropping into shell (exited $exit_code).${preset}
>> ${pbold}Scenario:${preset} ${pmagenta}$scenario${preset}
EOM
        # TODO: Best to NOT read heredoc from scenario?
        (set +e ; cd $tmpdir ; $SHELL -i)
    fi
}

function scenario {
    local run_script=$rootdir/svn-recommit.sh
    trap 'rm -rf $tmpdir' RETURN
    local tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t ${0##*/})
    local clientdir=$tmpdir/client

    local scenario='scenario'
    for arg
    do
        case $arg in
        *\'* ) scenario="$scenario \"$arg\"" ;;
        *' '* | *\"* ) scenario="$scenario '$arg'" ;;
        * ) scenario="$scenario $arg" ;;
        esac
    done

    local test_name="$1"
    shift

    case $1 in
    given_repo ) "$@" ;;
    * ) _bad_functions given_repo ;;
    esac
    local exit_code=$?

    (( 0 != exit_code )) && _maybe_debug_if_not_passed

    case $exit_code in
    0 ) let ++passed ;;
    1 ) let ++failed  ;;
    * ) let ++errored  ;;
    esac

    return $exit_code
}

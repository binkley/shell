# vi: ft=bash
# Source me

function first_time_in_repo {
    local -r stack=($(caller 0))
    local -r previous=${stack[1]}

    case $previous in
    GIVEN ) ;;
    * ) _bad_syntax before GIVEN ;;
    esac

    local -r repo_dir=$tmpdir/git
    git init $repo_dir >$stdout 2>$stderr
    cp gee $repo_dir
    cd $repo_dir
    git add gee
    git commit gee -m 'First commit' >/dev/null
}
_register first_time_in_repo

function _gee {
    # TODO: More elegant approach than multi-step and tmp file
    local -r tmp_stderr=$tmpdir/tmp_stderr
    ./gee $local_git $log_unchanged "${message[@]}" "$@" >$stdout 2>$tmp_stderr
    grep '^+' $tmp_stderr >&2
    grep -v '^+' $tmp_stderr >$stderr
    rm -f $tmp_stderr
}

function local_git {
    local -r local_git=-l
}
_register local_git

function having_message {
    local -r message=(-m "$1")
}
_register having_message 1

function log_unchanged {
    local -r log_unchanged=-u
}
_register log_unchanged

function run_echo {
    local -r command=(echo "$1")
}
_register run_echo 1

function with_program {
    _gee "${command[@]}"
}
_register with_program

function in_pipe {
    "${command[@]}" | _gee
}
_register in_pipe

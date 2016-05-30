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
}
_register first_time_in_repo

function run_echo {
    local -r command=(echo "$1")
    shift
    "$@"
}

function with_program {
    ./gee "${command[@]}" >$stdout 2>$stderr
}
_register with_program

function in_pipe {
    local -r message="$1"
    "${command[@]}" | ./gee -m "$message" >$stdout 2>$stderr
}
_register in_pipe 1

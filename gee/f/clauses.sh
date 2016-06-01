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

function local_git {
    local -r local_git=-l
}
_register local_git

function run_echo {
    local -r command=(echo "$1")
}
_register run_echo 1

function with_program {
    ./gee $local_git "${command[@]}" >$stdout 2>$stderr
}
_register with_program

function in_pipe {
    local -r message="$1"
    "${command[@]}" | ./gee $local_git -m "$message" >$stdout 2>$stderr
}
_register in_pipe 1

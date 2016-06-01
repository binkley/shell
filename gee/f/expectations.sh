# vi: ft=bash
# Source me

function exit_with {
    local actual=$?
    local expected=$1

    (( expected == actual ))
}
_register exit_with 1

function on_stderr {
    local expected
    case $1 in
    - ) read -d '' -r expected || true ;;
    * ) expected="$1" ;;
    esac
    shift

    local actual="$(<$stderr)"

    [[ "$expected" == "$actual" ]]
}
_register on_stderr 1

function on_stdout {
    local expected
    case $1 in
    - ) read -d '' -r expected || true ;;
    * ) expected="$1" ;;
    esac

    local actual="$(<$stdout)"

    [[ "$expected" == "$actual" ]]
}
_register on_stdout 1

function git_log_message {
    local expected
    case $1 in
    - ) read -d '' -r expected || true ;;
    * ) expected="$1" ;;
    esac

    [[ -z $local_git ]] && local -r gee_g='./gee -g'
    local actual="$($gee_g git log -1 --pretty=format:%s)"

    [[ "$expected" == "$actual" ]]
}
_register git_log_message 1

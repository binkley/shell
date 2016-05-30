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
_register on_stdout

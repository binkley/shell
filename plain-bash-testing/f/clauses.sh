# vi: ft=bash
# Source me

function make_exit {
    local -r e=$1
    shift
    (exit $e)
    "$@"
}

function check_exit {
    (( $? == $1 ))
}
_register check_exit 1

function check_d {
    [[ $PWD == $1 ]]
}
_register check_d 1

function push_d {
    pushd $1 >/dev/null
}
_register push_d 1

function change_d {
    cd $1
}
_register change_d 1

function terminal_variadic {
    :
}
_register terminal_variadic 1

function interior_variadic {
    for arg
    do
        case $arg in
        - ) shift ; break ;;
        * ) shift ;;
        esac
    done
}
_register interior_variadic

function early_return {
    return $1
}
_register early_return 1

function normal_return {
    (exit $1)
}
_register normal_return 1

function dynamic_scope {
    [[ "$bob" == nancy ]]
}
_register dynamic_scope

function f {
    local -r bob=nancy
}
_register f

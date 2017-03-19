function color_of {
    local -r fruit="$1"
    case $fruit in
    avacado ) echo greenish ;;
    orange ) echo orange ;;
    rambutan ) echo red ;;
    strawberry ) echo red ;;
    * ) echo "$0: Unknown fruit: $fruit" >&2
        return 2 ;;  # Not exit!
    esac
}

# For GIVEN - cannot fail or error, so do not `_register`
# Global (not local) so visible to later clauses
trap 'rm -rf $upstream $repodir' EXIT  # Must be outside of function
function a-repo {
    git_tdd=$PWD/git-tdd
    upstream=$(mktemp -d)
    git init --bare --quiet $upstream >/dev/null || return $?
    repodir=$(mktemp -d)
    git clone --quiet $upstream $repodir >/dev/null 2>&1 || return $?
    (cd $repodir \
        && touch Bob \
        && git add Bob \
        && git commit --quiet -a -m Initial \
        && git push --quiet -u origin master) >/dev/null
}
_register a-repo

# For WHEN
function tdd-init {
    (cd $repodir \
        && $git_tdd init \
        && git config --local tdd.testCommand true \
        && git config --local tdd.acceptCommand true) >/dev/null 2>&1
    exit_code=$?
}
_register tdd-init

function tdd-test {
    (cd $repodir \
        && $git_tdd test) >/dev/null
    exit_code=$?
}
_register tdd-test

# For THEN
function happy-path {
    (( 0 == exit_code ))
}
_register happy-path

function work-in-progress {
    local -r test_number=$1
    (cd $repodir \
        && number="$($git_tdd test-number)" \
        && (( test_number == number )) )
}
_register work-in-progress 1

function user-failed {
    (( 2 == exit_code ))
}
_register user-failed

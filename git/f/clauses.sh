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

function tdd-accept {
    local message="$1"
    (cd $repodir \
        && $git_tdd accept -m "$message") >/dev/null
    exit_code=$?
}
_register tdd-accept 1

function a-change {
    (cd $repodir \
        && echo NOK >Bob)
}
_register a-change

# For THEN
function happy-path {
    (( 0 == exit_code ))
}
_register happy-path

function no-changes {
    [[ -z "$(cd $repodir && git status --porcelain)" ]] \
        && (( 1 == $(cd $repodir \
            && git log origin/master..HEAD --format=%H | wc -l) ))
}
_register no-changes

function pushed-with {
    local message="$1"
    [[ "$message" == "$(cd $repodir && git log HEAD^^..HEAD^ --format=%s)" ]]
}
_register pushed-with 1

function _test-number {
    $git_tdd show --format=%N
}

function work-in-progress {
    local -r test_number=$1
    (cd $repodir \
        && number="$(_test-number)" \
        && (( test_number == number )) \
        && [[ WIP == "$(git log -1 --format=%s)" ]])
}
_register work-in-progress 1

function user-failed {
    (( 2 == exit_code ))
}
_register user-failed

function show-current-commit {
    (cd $repodir \
        && [[ WIP == $($git_tdd show --format=%s) ]] \
        && [[ 0 == $($git_tdd show --format=%N) ]] )
}
_register show-current-commit

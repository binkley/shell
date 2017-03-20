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

function a-failing-pre-push-hook {
    (cd $repodir \
        && ln -s /usr/bin/false .git/hooks/pre-push)
}
_register a-failing-pre-push-hook

# For WHEN
function tdd-init {
    (cd $repodir \
        && $git_tdd init \
        && git config --local tdd.testCommand 'echo test' \
        && git config --local tdd.acceptCommand 'echo accept') >/dev/null 2>&1
    exit_code=$?
}
_register tdd-init

function tdd-test {
    test_output="$(cd $repodir \
        && $git_tdd test)"
    exit_code=$?
}
_register tdd-test

function _tdd-accept {
    local -r message="$1"
    accept_output="$(cd $repodir \
        && $git_tdd accept --message "$message")"
    exit_code=$?
}

function tdd-accept {
    _tdd-accept "$@"
}
_register tdd-accept 1

function tdd-accept-ignoring-errors {
    _tdd-accept "$@" >/dev/null 2>&1
}
_register tdd-accept-ignoring-errors 1

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

function runs-test-command {
    [[ test == "$test_output" ]]
}
_register runs-test-command

function runs-accept-command {
    [[ accept == "$accept_output" ]]
}
_register runs-accept-command

function changes-committed {
    [[ -z "$(cd $repodir && git status --porcelain)" ]] \
        && (( 1 == $(cd $repodir \
            && git log origin/master..HEAD --format=%H | wc -l) ))
}
_register changes-committed

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

function shows-current-commit {
    (cd $repodir \
        && [[ WIP == $($git_tdd show --format=%s) ]] \
        && [[ 0 == $($git_tdd show --format=%N) ]] )
}
_register shows-current-commit

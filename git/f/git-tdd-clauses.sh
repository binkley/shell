# For GIVEN - cannot fail or error, so do not `_register`
# Global (not local) so visible to later clauses
function a-failing-pre-push-hook() (
    cd $repodir \
        && ln -s /usr/bin/false .git/hooks/pre-push
)
_register a-failing-pre-push-hook

# For WHEN
function _tdd-init {
    (cd $repodir \
        && $git_tdd init --quiet \
        && git config --local tdd.testCommand 'echo test' \
        && git config --local tdd.acceptCommand 'echo accept')
    exit_code=$?
}

function tdd-init {
    _tdd-init "$@"
}
_register tdd-init

function tdd-init-ignoring-errors {
    _tdd-init "$@" >/dev/null 2>&1
}
_register tdd-init-ignoring-errors

function pull-disabled {
    (cd $repodir \
        && git config --local tdd.pullBeforeTest false)
}
_register pull-disabled

function tdd-test {
    tdd_output="$(cd $repodir \
        && $git_tdd test)"
    exit_code=$?
}
_register tdd-test

function _tdd-accept {
    local -r message="$1"
    tdd_output="$(cd $repodir \
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

function _a-change() (
    cd $repodir \
        && echo NOK >$1
)

function a-change-to-existing {
    _a-change Bob
}
_register a-change-to-existing

function this-change {
    _a-change $1
}
_register this-change 1

function this-change-added() (
    cd $repodir \
        && git add $1
)
_register this-change-added 1

# For THEN
function happy-path() (( 0 == exit_code ))
_register this-change 1

function this-change-added() (
    cd $repodir \
        && git add $1
)
_register this-change-added 1

# For THEN
function happy-path() (( 0 == exit_code ))
_register happy-path

function runs-test-command() [[ test == "$tdd_output" ]]
_register runs-test-command

function runs-accept-command() [[ accept == "$tdd_output" ]]
_register runs-accept-command

# TODO: This assumes a remote upstream, not valid locally
# TODO: Overcomplex, pull out 2nd test
function changes-committed {
    [[ -z "$(cd $repodir && git status --porcelain)" ]] \
        && (( 1 == $(cd $repodir \
            && git log --format=%H origin/master..HEAD -- | wc -l) ))
}
_register changes-committed

function pushed-with {
    local message="$1"
    [[ "$message" == "$(cd $repodir && git log --format=%s HEAD^^..HEAD^ --)" ]]
}
_register pushed-with 1

function _changes-persist() (
    cd $repodir \
        && [[ -f $1 ]]
)

function changes-persist {
    _changes-persist Bob
}
_register changes-persist

function this-change-persists {
    _changes-persist $1
}
_register this-change-persists 1

function _test-number {
    $git_tdd status --format=%N
}

function work-in-progress {
    local -r test_number=$1
    (cd $repodir \
        && number="$(_test-number)" \
        && (( test_number == number )) \
        && [[ WIP == "$(git log -1 --format=%s)" ]])
}
_register work-in-progress 1

function user-failed() (( 2 == exit_code ))
_register user-failed

function shows-current-commit() (
    cd $repodir \
        && [[ WIP == $($git_tdd status --format=%s) ]] \
        && [[ 0 == $($git_tdd status --format=%N) ]]
)
_register shows-current-commit

function tdd-status {
    tdd_output="$(cd $repodir \
        && $git_tdd status 2>&1 | _strip-color-codes)"
    exit_code=$?
}
_register tdd-status

function not-initialized {
    _expected='Exit code 2'
    _actual="Exit code $exit_code"
    (( 2 == exit_code )) || return
    printf -v _expected "git-tdd: TDD not initialized (try 'git tdd init')\ngit-tdd: Failed."
    _actual="$tdd_output"
    [[ "$_expected" == "$_actual" ]]
}
_register not-initialized

function _strip-color-codes {
    sed 's/\x1B\[[0-9]*\(;[0-9]*\)*m//g'
}

function tdd-diff {
    tdd_output="$(cd $repodir \
        && $git_tdd diff 2>&1 | _strip-color-codes)"
    exit_code=$?
}
_register tdd-diff

function shows-no-differences {
    _expected="Untested:

WIP:"
    _actual="$tdd_output"
    [[ "$_expected" == "$_actual" ]]
}
_register shows-no-differences

function shows-untested-differences {
    _expected="Untested:
diff --git a/Bob b/Bob
index e69de29..256de1e 100644
--- a/Bob
+++ b/Bob
@@ -0,0 +1 @@
+NOK

WIP:
diff --git a/Bob b/Bob
new file mode 100644
index 0000000..e69de29"
    _actual="$tdd_output"
    [[ "$_expected" == "$_actual" ]]
}
_register shows-untested-differences

function shows-wip-differences {
    _expected="Untested:
diff --git a/Bob b/Bob
index e69de29..256de1e 100644
--- a/Bob
+++ b/Bob
@@ -0,0 +1 @@
+NOK

WIP:
diff --git a/Bob b/Bob
new file mode 100644
index 0000000..e69de29"
    _actual="$tdd_output"
    [[ "$_expected" == "$_actual" ]]
}
_register shows-wip-differences

# For GIVEN - cannot fail or error, so do not `_register`
# Global (not local) so visible to later clauses

readonly git_tdd=$PWD/git-tdd
readonly git_hooks=$PWD/git-hooks

function an-empty-repo-with-initial-empty-commit {
    _tmpdir repodir
    git init --quiet $repodir >/dev/null || return $?
    (cd $repodir \
        && git commit --quiet --allow-empty -m Initial >/dev/null)
}
_register an-empty-repo-with-initial-empty-commit

function a-cloned-repo-with-commits {
    _tmpdir upstream
    git init --bare --quiet $upstream >/dev/null || return $?
    _tmpdir repodir
    git clone --quiet $upstream $repodir >/dev/null 2>&1 || return $?
    (cd $repodir \
        && git commit --quiet --allow-empty -m Initial >/dev/null \
        && git push --quiet -u origin master >/dev/null \
        && touch Bob \
        && git add Bob \
        && git commit --quiet -a -m 'First Bob' \
        && git push --quiet -u origin master) >/dev/null
}
_register a-cloned-repo-with-commits

function a-local-repo-with-commits {
    _tmpdir repodir
    git init --quiet $repodir >/dev/null || return $?
    (cd $repodir \
        && git commit --quiet --allow-empty -m Initial >/dev/null \
        && touch Bob \
        && git add Bob \
        && git commit --quiet -a -m 'First Bob') >/dev/null
}
_register a-local-repo-with-commits

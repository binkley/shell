# For GIVEN - cannot fail or error, so do not `_register`
# Global (not local) so visible to later clauses

# TODO: Remove ALL tempdirs, not just most recent
trap 'rm -rf $upstream $repodir' EXIT  # Must be outside of function

function an-empty-repo-with-initial-empty-commit {
    git_tdd=$PWD/git-tdd
    git_hooks=$PWD/git-hooks
    repodir=$(mktemp -d)
    git init --quiet $repodir >/dev/null || return $?
    (cd $repodir \
        && git commit --quiet --allow-empty -m Initial >/dev/null)
}
_register an-empty-repo-with-initial-empty-commit

function a-cloned-repo-with-commits {
    git_tdd=$PWD/git-tdd
    git_hooks=$PWD/git-hooks
    upstream=$(mktemp -d)
    git init --bare --quiet $upstream >/dev/null || return $?
    repodir=$(mktemp -d)
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
    git_tdd=$PWD/git-tdd
    git_hooks=$PWD/git-hooks
    repodir=$(mktemp -d)
    git init --quiet $repodir >/dev/null || return $?
    (cd $repodir \
        && git commit --quiet --allow-empty -m Initial >/dev/null \
        && touch Bob \
        && git add Bob \
        && git commit --quiet -a -m 'First Bob') >/dev/null
}
_register a-local-repo-with-commits

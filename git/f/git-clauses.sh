# For GIVEN - cannot fail or error, so do not `_register`
# Global (not local) so visible to later clauses
trap 'rm -rf $upstream $repodir' EXIT  # Must be outside of function
# TODO: Remove ALL tempdirs, not just most recent
function a-repo {
    git_tdd=$PWD/git-tdd
    git_hooks=$PWD/git-hooks
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

function a-local-repo {
    git_tdd=$PWD/git-tdd
    git_hooks=$PWD/git-hooks
    repodir=$(mktemp -d)
    git init --quiet $repodir >/dev/null || return $?
    (cd $repodir \
        && touch Bob \
        && git add Bob \
        && git commit --quiet -a -m Initial) >/dev/null
}
_register a-local-repo

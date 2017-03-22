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

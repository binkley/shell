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
trap 'rm -rf $repodir' EXIT  # Must be outside of function
function a_repo {
    git_tdd=$PWD/git-tdd
    repodir=$(mktemp -d)
    git init $repodir >/dev/null || return $?
    (cd $repodir && touch Bob && git add Bob && git commit -a -m Initial) >/dev/null
}

# For WHEN
function tdd_init {
    (cd $repodir; $git_tdd init) >/dev/null
}

# For THEN
function work_in_progress {
    local -r test_number="$0"
}
_register work_in_progress 1

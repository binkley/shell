# WHEN
function hooks-list {
    list_output="$(cd $repodir \
        && git hooks list)"
}
_register hooks-list

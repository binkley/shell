SCENARIO 'TDD diff without init' \
    GIVEN a-cloned-repo-with-commits \
    WHEN tdd-diff \
    THEN user-failed \
        AND not-initialized

SCENARIO 'TDD diff on new WIP' \
    GIVEN a-cloned-repo-with-commits \
    WHEN tdd-init \
        AND tdd-diff \
    THEN happy-path \
        AND shows-no-differences

SCENARIO 'TDD diff on WIP with untested changes' \
    GIVEN a-cloned-repo-with-commits \
    WHEN tdd-init \
        AND a-change-to-existing \
        AND tdd-diff \
    THEN happy-path \
        AND shows-untested-differences

SCENARIO 'TDD diff WIP with tested changes' \
    GIVEN a-cloned-repo-with-commits \
    WHEN tdd-init \
        AND a-change-to-existing \
        AND tdd-test \
        AND tdd-diff \
    THEN happy-path \
        AND shows-wip-differences

# SCENARIO 'TDD diff WIP with mixed changes' \
#     GIVEN an-empty-repo-with-initial-empty-commit \
#     WHEN tdd-init \
#         AND a-change-to-existing \
#         AND tdd-test \
#         AND another-change-to-existing \
#         AND tdd-diff \
#     THEN happy-path \
#         AND shows-untested-and-wip-differences

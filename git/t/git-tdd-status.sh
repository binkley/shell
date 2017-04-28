SCENARIO 'TDD status on WIP' \
    GIVEN a-cloned-repo-with-commits \
    WHEN tdd-init \
    THEN shows-current-commit

SCENARIO 'TDD status on new repo' \
    GIVEN an-empty-repo-with-initial-empty-commit \
    WHEN tdd-status \
    THEN user-failed \
        AND not-initialized

SCENARIO 'TDD status on non-TDD repo' \
    GIVEN a-cloned-repo-with-commits \
    WHEN tdd-status \
    THEN user-failed \
        AND not-initialized

SCENARIO 'TDD status on WIP' \
    GIVEN a-repo \
    WHEN tdd-init \
    THEN shows-current-commit

SCENARIO 'TDD status on new repo' \
    GIVEN a-new-repo \
    WHEN tdd-status \
    THEN user-failed \
        AND status-complained

SCENARIO 'TDD status on non-TDD repo' \
    GIVEN a-repo \
    WHEN tdd-status \
    THEN user-failed \
        AND status-complained

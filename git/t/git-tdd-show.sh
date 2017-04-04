SCENARIO 'TDD show WIP' \
    GIVEN a-repo \
    WHEN tdd-init \
    THEN shows-current-commit

SCENARIO 'TDD show on new repo' \
    GIVEN a-new-repo \
    WHEN tdd-show \
    THEN user-failed \
        AND show-complained

SCENARIO 'TDD show on non-TDD repo' \
    GIVEN a-repo \
    WHEN tdd-show \
    THEN user-failed \
        AND show-complained

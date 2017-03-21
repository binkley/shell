SCENARIO 'TDD show WIP' \
    GIVEN a-repo \
    WHEN tdd-init \
    THEN shows-current-commit

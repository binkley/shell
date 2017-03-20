SCENARIO 'TDD init' \
    GIVEN a-repo \
    WHEN tdd-init \
    THEN happy-path \
        AND work-in-progress 0

SCENARIO 'TDD init twice' \
    GIVEN a-repo \
    WHEN tdd-init \
        AND tdd-init \
    THEN user-failed

SCENARIO 'TDD first test' \
    GIVEN a-repo \
    WHEN tdd-init \
        AND a-change \
        AND tdd-test \
    THEN happy-path \
        AND runs-test-command \
        AND changes-committed \
        AND work-in-progress 1

SCENARIO 'TDD simple accept' \
    GIVEN a-repo \
    WHEN tdd-init \
        AND a-change \
        AND tdd-test \
        AND tdd-accept 'Some work' \
    THEN happy-path \
        AND runs-accept-command \
        AND pushed-with 'Some work' \
        AND work-in-progress 0

SCENARIO 'TDD log' \
    GIVEN a-repo \
    WHEN tdd-init \
    THEN shows-current-commit

# These tests PASS

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
        AND no-changes \
        AND work-in-progress 1

SCENARIO 'TDD simple accept' \
    GIVEN a-repo \
    WHEN tdd-init \
        AND a-change \
        AND tdd-test \
        AND tdd-accept \
    THEN happy-path \
        AND work-in-progress 0

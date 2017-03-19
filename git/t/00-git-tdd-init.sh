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

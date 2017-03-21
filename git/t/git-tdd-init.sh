SCENARIO 'TDD init' \
    GIVEN a-repo \
    WHEN tdd-init \
    THEN happy-path \
        AND work-in-progress 0

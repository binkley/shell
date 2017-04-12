SCENARIO 'TDD init' \
    GIVEN a-cloned-repo-with-commits \
    WHEN tdd-init \
    THEN happy-path \
        AND work-in-progress 0

SCENARIO 'TDD init twice fails' \
    GIVEN a-cloned-repo-with-commits \
    WHEN tdd-init \
        AND tdd-init-ignoring-errors \
    THEN user-failed

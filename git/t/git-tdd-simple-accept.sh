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

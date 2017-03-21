SCENARIO 'TDD first test' \
    GIVEN a-repo \
    WHEN tdd-init \
        AND a-change \
        AND tdd-test \
    THEN happy-path \
        AND runs-test-command \
        AND changes-committed \
        AND work-in-progress 1

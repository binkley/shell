SCENARIO 'TDD first test' \
    GIVEN a-repo \
    WHEN tdd-init \
        AND a-change \
        AND tdd-test \
    THEN happy-path \
        AND runs-test-command \
        AND changes-committed \
        AND work-in-progress 1

SCENARIO 'TDD test without pull' \
    GIVEN a-repo \
    WHEN tdd-init \
        AND a-change \
        AND pull-disabled \
        AND tdd-test \
    THEN happy-path \
        AND changes-persist \
        AND work-in-progress 1

SCENARIO 'TDD test without pull on new change' \
    GIVEN a-repo \
    WHEN tdd-init \
        AND pull-disabled \
        AND this-change Fred \
        AND this-change-added Fred \
        AND tdd-test \
    THEN happy-path \
        AND this-change-persists Fred \
        AND work-in-progress 1

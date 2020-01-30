SCENARIO 'TDD first test' \
    GIVEN a-cloned-repo-with-commits \
    WHEN tdd-init \
        AND a-change-to-existing \
        AND tdd-test \
    THEN happy-path \
        AND runs-test-command \
        AND changes-committed \
        AND work-in-progress 1

SCENARIO 'TDD two tests' \
    GIVEN a-cloned-repo-with-commits \
    WHEN tdd-init \
        AND a-change-to-existing \
        AND tdd-test \
        AND this-change Fred \
        AND this-change-added Fred \
        AND tdd-test \
    THEN happy-path \
        AND runs-test-command \
        AND changes-committed \
        AND work-in-progress 2

SCENARIO 'TDD test without pull' \
    GIVEN a-cloned-repo-with-commits \
    WHEN tdd-init \
        AND a-change-to-existing \
        AND pull-before-test-disabled \
        AND tdd-test \
    THEN happy-path \
        AND changes-persist \
        AND work-in-progress 1

SCENARIO 'TDD test without pull on new change' \
    GIVEN a-cloned-repo-with-commits \
    WHEN tdd-init \
        AND pull-before-test-disabled \
        AND this-change Fred \
        AND this-change-added Fred \
        AND tdd-test \
    THEN happy-path \
        AND this-change-persists Fred \
        AND work-in-progress 1

SCENARIO 'TDD test without remote should not pull' \
    GIVEN a-local-repo-with-commits \
    WHEN tdd-init \
        AND this-change Fred \
        AND this-change-added Fred \
        AND tdd-test \
    THEN happy-path \
        AND this-change-persists Fred \
        AND work-in-progress 1

SCENARIO 'TDD test with no changes' \
    GIVEN a-cloned-repo-with-commits \
    WHEN tdd-init \
        AND tdd-test \
    THEN happy-path \
        AND work-in-progress 0

SCENARIO 'TDD test fails should revert' \
    GIVEN a-cloned-repo-with-commits \
    WHEN tdd-init \
        AND revert-on-fail-enabled \
        AND a-change-to-existing \
        AND failing-tests \
        AND tdd-test \
    THEN sad-path \
        AND the-repo-is-clean

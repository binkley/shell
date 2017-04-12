SCENARIO 'TDD simple accept' \
    GIVEN a-cloned-repo-with-commits \
    WHEN tdd-init \
        AND a-change-to-existing \
        AND tdd-accept 'Some work' \
    THEN happy-path \
        AND runs-accept-command \
        AND pushed-with 'Some work' \
        AND work-in-progress 0

SCENARIO 'Git hook fails, TDD recovers' \
    GIVEN a-cloned-repo-with-commits \
        AND a-failing-pre-push-hook \
    WHEN tdd-init \
        AND a-change-to-existing \
        AND tdd-accept-ignoring-errors 'It fails' \
    THEN work-in-progress 0

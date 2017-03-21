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

SCENARIO 'Git hook fails, TDD recovers' \
    GIVEN a-repo \
        AND a-failing-pre-push-hook \
    WHEN tdd-init \
        AND a-change \
        AND tdd-accept-ignoring-errors 'It fails' \
    THEN work-in-progress 1

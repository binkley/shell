SCENARIO 'Git hook fails, TDD recovers' \
    GIVEN a-repo \
        AND a-failing-pre-push-hook \
    WHEN tdd-init \
        AND a-change \
        AND tdd-accept-ignoring-errors 'It fails' \
    THEN work-in-progress 1

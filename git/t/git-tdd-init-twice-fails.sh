SCENARIO 'TDD init twice fails' \
    GIVEN a-repo \
    WHEN tdd-init \
        AND tdd-init-ignoring-errors \
    THEN user-failed

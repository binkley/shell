SCENARIO 'HOOKS lists none installed' \
    GIVEN a-repo \
    WHEN hooks-init \
    THEN hooks-installed

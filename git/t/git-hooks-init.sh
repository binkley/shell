SCENARIO 'HOOKS lists none installed' \
    GIVEN a-cloned-repo-with-commits \
    WHEN hooks-init \
    THEN hooks-installed

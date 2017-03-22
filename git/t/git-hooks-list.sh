SCENARIO 'HOOKS lists no pre-commit installed' \
    GIVEN a-repo \
    WHEN hooks-init \
        AND hooks-list pre-commit \
    THEN output-is ''

SCENARIO 'HOOKS lists one pre-commit installed' \
    GIVEN a-repo \
    WHEN hooks-init \
        AND add-hook pre-commit good \
        AND hooks-list pre-commit \
    THEN output-is 'good'

# vi: ft=bash
# Source me

SCENARIO 'Run echo on command line' \
    GIVEN first_time_in_repo \
    WHEN run_echo 'Uncle Bob' \
        with_program \
    THEN exit_with 0 \
        AND on_stdout 'Uncle Bob'


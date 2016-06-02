# vi: ft=bash
# Source me

SCENARIO 'Run same output' \
    GIVEN first_time_in_repo \
    WHEN run_echo 'Uncle Bob' with_program \
        AND run_echo 'Uncle Bob' having_message 'Second time' with_program \
    THEN git_log_message 'echo Uncle Bob'

SCENARIO 'Run same output but do log unchanged' \
    GIVEN first_time_in_repo \
    WHEN run_echo 'Uncle Bob' with_program \
        AND run_echo 'Uncle Bob' having_message 'Second time' log_unchanged with_program \
    THEN git_log_message - <<EOM
echo Uncle Bob

Second time
EOM

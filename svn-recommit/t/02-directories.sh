scenario "Add a directory and edit commit message" \
    given_repo \
        and_add_directory with_message "A commit" \
    when_recommit with_message "B commit" \
    then_editor_was <<'EOB' \
        and_first_line_replaced
A commit
--This line, and those below, will be ignored--

A    /x
EOB

scenario "Move a directory and edit commit message" \
    given_repo \
        and_move_directory with_message "A commit" \
    when_recommit with_message "B commit" \
    then_editor_was <<'EOB' \
        and_first_line_replaced
A commit
--This line, and those below, will be ignored--

D    /x
A    /y (from /x:2)
EOB

scenario "Delete a directory and edit commit message" \
    given_repo \
        and_delete_directory with_message "A commit" \
    when_recommit with_message "B commit" \
    then_editor_was <<'EOB' \
        and_first_line_replaced
A commit
--This line, and those below, will be ignored--

D    /x
EOB

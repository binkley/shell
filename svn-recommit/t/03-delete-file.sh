scenario "Delete a file and edit commit message" \
    given_repo \
        and_delete_file with_message "A commit" \
    when_recommit with_message "B commit" \
    then_editor_was <<'EOB' \
        and_first_line_replaced
A commit
--This line, and those below, will be ignored--

D    /a-file
EOB

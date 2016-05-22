# vi: ft=bash
# Source me

SCENARIO "Variadic with none" f AND variadic
SCENARIO "Variadic with one" f AND variadic apple
SCENARIO "Dynamic scope" f AND dynamic_scope
SCENARIO "Check exit" make_exit 1 AND check_exit 1

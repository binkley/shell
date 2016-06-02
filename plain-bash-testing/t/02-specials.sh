# vi: ft=bash
# Source me

SCENARIO 'Terminal variadic with none' f AND terminal_variadic
SCENARIO 'Terminal variadic with one' f AND terminal_variadic apple
SCENARIO 'Interior variadic' f AND interior_variadic apple orange - AND normal_return 0
SCENARIO 'Dynamic scope' f AND dynamic_scope
SCENARIO 'Check exit' make_exit 1 AND check_exit 1

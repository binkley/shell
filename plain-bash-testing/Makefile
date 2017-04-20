SHELL = bash

check:
	@diff --color=auto \
	    <(./run-tests t | grep 'Summary: .* PASSED, .* FAILED, .* ERRORED') \
	    <(echo 'Summary: 15 PASSED, 4 FAILED, 4 ERRORED')
	@diff --color=auto \
	    <(./run-tests --pattern=indirect t | grep 'Summary: .* PASSED, .* FAILED, .* ERRORED') \
	    <(echo 'Summary: 2 PASSED, 2 FAILED, 2 ERRORED')

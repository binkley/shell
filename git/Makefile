SHELL = bash

check:
	@diff --color=auto \
		<(./run-tests t | grep 'Summary: .* PASSED, .* FAILED, .* ERRORED') \
		<(echo 'Summary: 21 PASSED, 0 FAILED, 0 ERRORED')

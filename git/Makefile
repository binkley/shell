SHELL = bash

test:
	@diff --color=always \
		<(./run-tests t | grep 'Summary: .* PASSED, .* FAILED, .* ERRORED') \
		<(echo 'Summary: 16 PASSED, 0 FAILED, 0 ERRORED')

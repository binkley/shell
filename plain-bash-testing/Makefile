SHELL = bash

check:
	@diff --color=auto <(./run-tests --color=never t) run-tests-expected.out
	@diff --color=auto \
	    <(./run-tests --color=never --pattern=indirect t | grep 'Summary: .* PASSED, .* FAILED, .* ERRORED') \
	    <(echo 'Summary: 2 PASSED, 2 FAILED, 2 ERRORED')

clean:
	@true

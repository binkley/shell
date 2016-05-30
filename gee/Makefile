SHELL=/bin/bash

test:
	@[ -t 1 ] && flags=-c ; \
		./test-gee -i -- $$flags t | grep 'Summary: 2 PASSED, 0 FAILED, 0 ERRORED' >/dev/null

SHELL = bash

all: man check

man:
	@for page in man1/*.ronn ; do ronn --roff $$page ; done

check:
	@diff --color=auto \
		<(./run-tests t | grep 'Summary: .* PASSED, .* FAILED, .* ERRORED') \
		<(echo 'Summary: 22 PASSED, 0 FAILED, 0 ERRORED')

clean:
	@for page in man1/*.ronn ; do rm -f $${page%.ronn} ; done

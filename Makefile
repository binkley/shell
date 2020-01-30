SHELL = bash

all: check

check:
	@./run-tests >/dev/null

clean:
	@./run-clean >/dev/null

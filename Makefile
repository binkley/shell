test:
	:;{ \
	export PATH=$$PWD/bin:$$PATH ; \
	for t in t/* ; \
	do \
	    test -x $$t && $$t ; \
	done ; \
	}

test:
	export PATH=$$PWD:$$PATH
	for t in t/* ; \
	do \
	    . $$t ; \
	done

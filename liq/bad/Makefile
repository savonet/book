LIQ = $(wildcard *.liq)

all:

check:
	@for l in $(LIQ); do \
	  echo -n "Checking $$l..."; \
	  liquidsoap --check $$l; \
	  echo " failed as expected."; \
	done

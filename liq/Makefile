LIQ = $(sort $(wildcard *.liq))

all:

check:
	@for l in $(LIQ); do \
	  echo -n "Checking $$l..."; \
	  liquidsoap --check $$l || exit 1 && \
	  echo " ok."; \
	done

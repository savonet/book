LIQ = $(wildcard *.liq)

all:

check:
	@for l in $(filter-out fallible1.liq,$(LIQ)); do \
	  echo -n "Checking $$l..."; \
	  liquidsoap --check $$l && \
	  echo " ok."; \
	done

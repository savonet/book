LIQ = $(filter-out convert2wav.liq, $(sort $(wildcard *.liq)))

all:

test.mp3:
	@echo "Generating a sine test mp3 file..."
	ffmpeg -f lavfi -i "sine=frequency=440:duration=5" -ac 2 $@

check:
	@for l in $(LIQ); do \
	  echo -n "Checking $$l..."; \
	  liquidsoap --check $$l || exit 1 && \
	  echo " ok."; \
	done

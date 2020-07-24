LIQ = $(filter-out convert2wav.liq, $(sort $(wildcard *.liq)))
CHECKS = $(foreach l, $(LIQ), check-$(basename $l))

all: test

test: check test.mp3
	./convert2wav.liq test.mp3

x:
	./convert2wav.liq test.mp3

test.mp3:
	@echo "Generating a sine test mp3 file..."
	ffmpeg -f lavfi -i "sine=frequency=440:duration=5" -ac 2 $@

check: $(CHECKS)

check-%: %.liq
	@echo -n "Checking $(basename $<)..."
	@./liquidsoap --check $< || exit 1
	@echo " ok."

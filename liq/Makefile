LIQ := $(filter-out convert2wav.liq, $(sort $(wildcard *.liq)))
CHECKS := $(foreach l, $(LIQ), check-$(basename $l))
CHECKS := $(filter-out check-ladspa.fastlookaheadlimiter, $(CHECKS))

LIQUIDSOAP = ./liquidsoap

all: files test

youtube:
	ffmpeg -re -stream_loop -1 -i video.mkv -i test.mp3 -vcodec libx264 -pix_fmt yuv420p -preset:v superfast -codec:a libmp3lame -b:a 160k -f flv rtmp://a.rtmp.youtube.com/live2/$(shell cat youtube-key)

test: youtube-key check test-wav

test-wav: test.mp3
	$(LIQUIDSOAP) -q convert2wav.liq -- test.mp3

test.mp3:
	@echo "Generating a sine test mp3 file..."
	ffmpeg -f lavfi -i "sine=frequency=440:duration=5" -ac 2 $@

files: ad.mp3 jingle1.mp3 jingle2.mp3 jingle3.mp3 video.mkv test1.png test2.png test3.png test4.png

ad.mp3:
	ffmpeg -f lavfi -i "sine=frequency=880:duration=1" -ac 2 $@

jingle1.mp3:
	ffmpeg -f lavfi -i "sine=frequency=220:duration=1" -ac 2 $@

jingle2.mp3:
	ffmpeg -f lavfi -i "sine=frequency=440:duration=1" -ac 2 $@

jingle3.mp3:
	ffmpeg -f lavfi -i "sine=frequency=880:duration=1" -ac 2 $@

test%.png test%.jpg:
	convert -pointsize 100 -size 500x500 caption:$@ $@

video.mkv:
	ffmpeg -f lavfi -i testsrc=duration=5:size=1280x720:rate=25 $@

youtube-key:
	touch $@

check: $(CHECKS)

check-%: %.liq
	@echo -n "Checking $(basename $<)..."
	@LIQ_LILV=false LIQ_LADSPA=false LIQ_DSSI=false $(LIQUIDSOAP) --check $< || exit 1
	@echo " ok."

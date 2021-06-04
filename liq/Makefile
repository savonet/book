LIQ := $(filter-out convert2wav.liq, $(sort $(wildcard *.liq)))
CHECKS := $(foreach l, $(LIQ), check-$(basename $l))
CHECKS := $(filter-out check-ladspa.fastlookaheadlimiter check-frei0r check-encoder-gstreamer-1 check-encoder-gstreamer-2 check-encoder-gstreamer-3 check-encoder-gstreamer-4 check-encoder-gstreamer-5 check-encoder-gstreamer-pipeline check-input.gstreamer check-input.gstreamer2 check-http.head, $(CHECKS))

LIQUIDSOAP = ./liquidsoap

all: files test

youtube:
	ffmpeg -re -stream_loop -1 -i video.mkv -i test.mp3 -vcodec libx264 -pix_fmt yuv420p -preset:v superfast -codec:a libmp3lame -b:a 160k -f flv rtmp://a.rtmp.youtube.com/live2/$(shell cat youtube-key)

test: check test-wav

test-wav: test.mp3
	$(LIQUIDSOAP) -q convert2wav.liq -- test.mp3

test.mp3:
	@echo "Generating a sine test mp3 file..."
	ffmpeg -f lavfi -i "sine=frequency=440:duration=5" -ac 2 $@

files: ad.mp3 jingle1.mp3 jingle2.mp3 jingle3.mp3 video.mkv test1.png test2.png test3.png test4.png fallback.mp3 lf.mp4 test.avi youtube-key facebook-key twitch-key

ad.mp3:
	ffmpeg -f lavfi -i "sine=frequency=880:duration=1" -ac 2 $@

jingle1.mp3:
	ffmpeg -f lavfi -i "sine=frequency=220:duration=1" -ac 2 $@

jingle2.mp3:
	ffmpeg -f lavfi -i "sine=frequency=440:duration=1" -ac 2 $@

jingle3.mp3:
	ffmpeg -f lavfi -i "sine=frequency=880:duration=1" -ac 2 $@

fallback.mp3:
	ffmpeg -f lavfi -i "sine=frequency=440:duration=5" -ac 2 $@

test%.png test%.jpg:
	convert -pointsize 100 -size 500x500 caption:$@ $@

video.mkv testsrc.mp4 testsrc.avi testsrc.ogv testsrc.mkv lf.mp4 test.avi:
	ffmpeg -f lavfi -i testsrc=duration=5:size=1280x720:rate=25 -f lavfi -i sine=f=440:d=5 -c:v libx264 $@

testsrc.webm:
	ffmpeg -f lavfi -i testsrc=duration=5:size=1280x720:rate=25 -f lavfi -i sine=f=440:d=5 -c:a libopus -c:v vp9 -b:a 128k -b:v 2500k $@

youtube-key facebook-key twitch-key:
	touch $@

check:
	@rm -f failed
	@$(MAKE) $(CHECKS)
	@if [ -e failed ]; then echo "Some tests failed!!!"; echo; cat failed exit 1; fi

check-%: %.liq
	@echo -n "Checking $(basename $<)..."
	@if LIQ_LILV=false LIQ_LADSPA=false LIQ_DSSI=false $(LIQUIDSOAP) --check $< ; then echo " ok." ; else echo "$<" >> "failed" ; echo " failed!" ; fi

docker-shell:
	docker run -it --entrypoint /bin/bash savonet/liquidsoap:main

docker-sine:
	docker run -it -v /dev/snd:/dev/snd --privileged savonet/liquidsoap:main liquidsoap 'output.alsa(sine())'

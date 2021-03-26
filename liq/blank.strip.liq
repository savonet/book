#!/usr/bin/env liquidsoap
mic   = buffer(input.alsa())
mic   = blank.strip(max_blank=2., min_noise=.1, threshold=-20., mic)
music = playlist("~/Music")
radio = fallback(track_sensitive=false, [mic, music])
output(radio)

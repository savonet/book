#!/usr/bin/env liquidsoap
# header
mic   = buffer(input.alsa())
mic   = blank.strip(max_blank=2., min_noise=.1, threshold=-20., mic)
music = playlist("~/Music")
radio = fallback([mic, music])
# footer
output(radio)

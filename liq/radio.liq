#!/bin/env liquidsoap
# Set up the playlists
day   = playlist("/radio/day.pls")   # Day music
night = playlist("/radio/night.pls") # Night music
mic   = buffer(input.alsa())         # Microphone
radio = switch([({8h-19h}, day), ({19h-20h}, mic), ({20h-8h}, night)])
# Add crossfading
radio = crossfade(fade_out=3., fade_in=3., duration=5., radio)
# Add jingles
jingles = playlist("/radio/jingls.pls")
radio = random(weights=[1, 4], [jingles, radio])
# Add some audio effects
radio = nrj(normalize(radio))
# Just in case, a fallback
radio = fallback([radio, single("fallback.mp3")])
# Output to icecast both in mp3 and aac
output.icecast(%mp3,    host="localhost", port=8000, password="hackme",
               mount="my-radio.mp3", radio)
output.icecast(%fdkaac, host="localhost", port=8000, password="hackme",
               mount="my-radio.aac", radio)

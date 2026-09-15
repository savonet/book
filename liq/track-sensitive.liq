#!/usr/bin/env liquidsoap
day   = playlist("/radio/day.pls")   # Day music
night = playlist("/radio/night.pls") # Night music
mic   = buffer(input.alsa())         # Microphone
# header
day = day.{track_sensitive = false}
# footer
radio = switch([({8h-19h}, day), ({19h-20h}, mic), ({20h-8h}, night)])
output(radio)
